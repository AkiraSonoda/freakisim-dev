/*
 * Copyright (c) Contributors, http://opensimulator.org/
 * See CONTRIBUTORS.TXT for a full list of copyright holders.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the OpenSimulator Project nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE DEVELOPERS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

using log4net;
using Nini.Config;
using OpenMetaverse;
using OpenSim.Framework;
using OpenSim.Framework.Communications;
using OpenSim.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

// AKIDO required includes
using OpenMetaverse.StructuredData;
using OpenSim.Server.Base;
using System.Xml;
using System.Xml.Serialization;

namespace OpenSim.Services.Connectors
{
    public class AssetServicesConnector : BaseServiceConnector, IAssetService
    {
        private static readonly ILog m_log =
                LogManager.GetLogger(
                MethodBase.GetCurrentMethod().DeclaringType);

        private string m_ServerURI = String.Empty;
        private IImprovedAssetCache m_Cache = null;
        private int m_maxAssetRequestConcurrency = 30;
        
        private delegate void AssetRetrievedEx(AssetBase asset);

        // AKIDO Surabaya URL
        private string surabayaServerURI = String.Empty;
        private bool surabayaServerEnabled = true;

        // Keeps track of concurrent requests for the same asset, so that it's only loaded once.
        // Maps: Asset ID -> Handlers which will be called when the asset has been loaded
        private Dictionary<string, AssetRetrievedEx> m_AssetHandlers = new Dictionary<string, AssetRetrievedEx>();

        public int MaxAssetRequestConcurrency
        {
            get { return m_maxAssetRequestConcurrency; }
            set { m_maxAssetRequestConcurrency = value; }
        }

        public AssetServicesConnector()
        {
        }

        public AssetServicesConnector(string serverURI)
        {
            m_ServerURI = serverURI.TrimEnd('/');
        }

        public AssetServicesConnector(IConfigSource source)
            : base(source, "AssetService")
        {
            Initialise(source);
        }

        public virtual void Initialise(IConfigSource source)
        {
            IConfig netconfig = source.Configs["Network"];
            if (netconfig != null)
                m_maxAssetRequestConcurrency = netconfig.GetInt("MaxRequestConcurrency",m_maxAssetRequestConcurrency);

            IConfig assetConfig = source.Configs["AssetService"];
            if (assetConfig == null)
            {
                m_log.Error("[ASSET CONNECTOR]: AssetService missing from OpenSim.ini");
                throw new Exception("Asset connector init error");
            }

            string serviceURI = assetConfig.GetString("AssetServerURI",
                    String.Empty);

            if (serviceURI == String.Empty)
            {
                m_log.Error("[ASSET CONNECTOR]: No Server URI named in section AssetService");
                throw new Exception("Asset connector init error");
            }

            m_ServerURI = serviceURI;

            // AKIDO Get Surabaya Server URI from ini file
            IConfig surabayaConfig = source.Configs["SurabayaServer"];
            if (surabayaConfig != null) {
                surabayaServerURI = surabayaConfig.GetString ("SurabayaServerURI");
                surabayaServerEnabled = surabayaConfig.GetBoolean ("Enabled");
                m_log.DebugFormat ("[AssetServicesConnector]: Surabaya ServerURI: {0}", surabayaServerURI);
            } else {
                m_log.Warn ("[AssetServicesConnector]: Surabaya Config is missing, defaulting to http://localhost:8080");
                surabayaServerEnabled = true;
                surabayaServerURI = "http://localhost:8080";
            }

        }

        protected void SetCache(IImprovedAssetCache cache)
        {
            m_Cache = cache;
        }

        public AssetBase Get(string id)
        {
//            m_log.DebugFormat("[ASSET SERVICE CONNECTOR]: Synchronous get request for {0}", id);

            string uri = m_ServerURI + "/assets/" + id;

            AssetBase asset = null;
            if (m_Cache != null)
                asset = m_Cache.Get(id);

            if (asset == null)
            {
                asset = SynchronousRestObjectRequester.MakeRequest<int, AssetBase>("GET", uri, 0, m_Auth);

                if (m_Cache != null)
                    m_Cache.Cache(asset);
            }
            return asset;
        }

        public AssetBase GetCached(string id)
        {
//            m_log.DebugFormat("[ASSET SERVICE CONNECTOR]: Cache request for {0}", id);

            if (m_Cache != null)
                return m_Cache.Get(id);

            return null;
        }

        public AssetMetadata GetMetadata(string id)
        {
            if (m_Cache != null)
            {
                AssetBase fullAsset = m_Cache.Get(id);

                if (fullAsset != null)
                    return fullAsset.Metadata;
            }

            string uri = m_ServerURI + "/assets/" + id + "/metadata";

            AssetMetadata asset = SynchronousRestObjectRequester.MakeRequest<int, AssetMetadata>("GET", uri, 0, m_Auth);
            return asset;
        }

        public byte[] GetData(string id)
        {
            if (m_Cache != null)
            {
                AssetBase fullAsset = m_Cache.Get(id);

                if (fullAsset != null)
                    return fullAsset.Data;
            }

            RestClient rc = new RestClient(m_ServerURI);
            rc.AddResourcePath("assets");
            rc.AddResourcePath(id);
            rc.AddResourcePath("data");

            rc.RequestMethod = "GET";

            Stream s = rc.Request();

            if (s == null)
                return null;

            if (s.Length > 0)
            {
                byte[] ret = new byte[s.Length];
                s.Read(ret, 0, (int)s.Length);

                return ret;
            }

            return null;
        }

        public bool Get(string id, Object sender, AssetRetrieved handler)
        {
//            m_log.DebugFormat("[ASSET SERVICE CONNECTOR]: Potentially asynchronous get request for {0}", id);

            string uri = m_ServerURI + "/assets/" + id;

            AssetBase asset = null;
            if (m_Cache != null)
                asset = m_Cache.Get(id);

            if (asset == null)
            {
                AssetRetrievedEx handlerEx = new AssetRetrievedEx(delegate(AssetBase _asset) { handler(id, sender, _asset); });

                lock (m_AssetHandlers)
                {

                    AssetRetrievedEx handlers;
                    if (m_AssetHandlers.TryGetValue(id, out handlers))
                    {
                        // Someone else is already loading this asset. It will notify our handler when done.
                        handlers += handlerEx;
                        return true;
                    }

                    // Load the asset ourselves
                    handlers += handlerEx;
                    m_AssetHandlers.Add(id, handlers);
                }

                bool success = false;
                try
                {
                    AsynchronousRestObjectRequester.MakeRequest<int, AssetBase>("GET", uri, 0,
                        delegate(AssetBase a)
                        {
                            if (a != null && m_Cache != null)
                                m_Cache.Cache(a);

                            AssetRetrievedEx handlers;
                            lock (m_AssetHandlers)
                            {
                                handlers = m_AssetHandlers[id];
                                m_AssetHandlers.Remove(id);
                            }
                            handlers.Invoke(a);
                        }, m_maxAssetRequestConcurrency, m_Auth);
                    
                    success = true;
                }
                finally
                {
                    if (!success)
                    {
                        lock (m_AssetHandlers)
                        {
                            m_AssetHandlers.Remove(id);
                        }
                    }
                }
            }
            else
            {
                handler(id, sender, asset);
            }

            return true;
        }

        public virtual bool[] AssetsExist(string[] ids)
        {
            string uri = m_ServerURI + "/get_assets_exist";

            bool[] exist = null;
            try
            {
                exist = SynchronousRestObjectRequester.MakeRequest<string[], bool[]>("POST", uri, ids, m_Auth);
            }
            catch (Exception)
            {
                // This is most likely to happen because the server doesn't support this function,
                // so just silently return "doesn't exist" for all the assets.
            }
            
            if (exist == null)
                exist = new bool[ids.Length];

            return exist;
        }

        public string Store(AssetBase asset)
        {
            if (asset.Local)
            {
                if (m_Cache != null)
                    m_Cache.Cache(asset);

                try {
                    // it is also possible to disable Surabaya. I'd favor to configure
                    // Surabaya in the CAPS Section of the OpenSim.ini but right now with still some
                    // old Viwers which do not support http getTexture() I stick to this hack.
                    if(surabayaServerEnabled) {
                        // Create an XML of the Texture in order to transport the Asset to Surabaya.
                        if (asset.Type == (sbyte) AssetType.Texture) {
                            XmlSerializer xs = new XmlSerializer(typeof(AssetBase));
                            byte[] result = ServerUtils.SerializeResult(xs, asset);
                            string resultString = Util.UTF8.GetString(result);
                            // AKIDO: remove commented code
                            //m_log.DebugFormat("Dump of XML: {0}", resultString);
                            OSDMap serializedAssetCaps = new OSDMap();
                            serializedAssetCaps.Add("assetID", asset.ID);
                            if(asset.Temporary) {
                                serializedAssetCaps.Add("temporary", "true");
                            } else {
                                serializedAssetCaps.Add("temporary", "false");
                            }
                            serializedAssetCaps.Add("serializedAsset", resultString);

                            int tickstart = Environment.TickCount;

                            OSDMap surabayaAnswer = WebUtil.PostToServiceCompressed(surabayaServerURI+"/cachetexture", serializedAssetCaps, 3000);

                            if(surabayaAnswer != null) {
                                // m_log.InfoFormat("Caching baked Texture: {0}",surabayaAnswer.ToString());
                                OSDBoolean isSuccess = (OSDBoolean) surabayaAnswer["Success"];
                                if(isSuccess) {
                                    OSDMap answer = (OSDMap) surabayaAnswer["_Result"];
                                    string surabayaResult = answer["result"];
                                    if(!surabayaResult.Equals("ok")) {
                                        m_log.ErrorFormat("Error PostingAgent Data: {0}", surabayaAnswer["reason"]);
                                    } else {
                                        m_log.InfoFormat("Caching baked Texture {0} was successful in {1}ms", asset.ID, Environment.TickCount - tickstart);
                                    }
                                } else {
                                    m_log.InfoFormat("Caching baked Texture {0} was not successful: {1}", asset.ID, surabayaAnswer["Message"]);
                                }
                            } else {
                                m_log.ErrorFormat("Caching baked texture {0} to Surabaya returned NULL after {1}ms", asset.ID , Environment.TickCount - tickstart );
                            }
                        }
                    }
                } catch (Exception ex) {
                    m_log.Error("Exception while caching baked texture to Surabaya: ", ex);
                }

                return asset.ID;
            }

            string uri = m_ServerURI + "/assets/";

            string newID;
            try
            {
                newID = SynchronousRestObjectRequester.MakeRequest<AssetBase, string>("POST", uri, asset, m_Auth);
            }
            catch (Exception e)
            {
                m_log.Warn(string.Format("[ASSET CONNECTOR]: Unable to send asset {0} to asset server. Reason: {1} ", asset.ID, e.Message), e);
                return string.Empty;
            }

            // TEMPORARY: SRAS returns 'null' when it's asked to store existing assets
            if (newID == null)
            {
                m_log.DebugFormat("[ASSET CONNECTOR]: Storing of asset {0} returned null; assuming the asset already exists", asset.ID);
                return asset.ID;
            }

            if (string.IsNullOrEmpty(newID))
                return string.Empty;

            asset.ID = newID;

            if (m_Cache != null)
                m_Cache.Cache(asset);

            return newID;
        }

        public bool UpdateContent(string id, byte[] data)
        {
            AssetBase asset = null;

            if (m_Cache != null)
                asset = m_Cache.Get(id);

            if (asset == null)
            {
                AssetMetadata metadata = GetMetadata(id);
                if (metadata == null)
                    return false;

                asset = new AssetBase(metadata.FullID, metadata.Name, metadata.Type, UUID.Zero.ToString());
                asset.Metadata = metadata;
            }
            asset.Data = data;

            string uri = m_ServerURI + "/assets/" + id;

            if (SynchronousRestObjectRequester.MakeRequest<AssetBase, bool>("POST", uri, asset, m_Auth))
            {
                if (m_Cache != null)
                    m_Cache.Cache(asset);

                return true;
            }
            return false;
        }

        public bool Delete(string id)
        {
            string uri = m_ServerURI + "/assets/" + id;

            if (SynchronousRestObjectRequester.MakeRequest<int, bool>("DELETE", uri, 0, m_Auth))
            {
                if (m_Cache != null)
                    m_Cache.Expire(id);

                return true;
            }
            return false;
        }
    }
}
