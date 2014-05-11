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

using Mono.Addins;
using Nini.Config;
using OpenMetaverse;
using OpenSim.Capabilities.Handlers;
using OpenSim.Region.Framework.Interfaces;
using OpenSim.Region.Framework.Scenes;
using OpenSim.Services.Interfaces;
using System;
using Caps = OpenSim.Framework.Capabilities.Caps;

namespace OpenSim.Region.ClientStack.Linden
{

    [Extension(Path = "/OpenSim/RegionModules", NodeName = "RegionModule", Id = "GetTextureModule")]
    public class GetTextureModule : INonSharedRegionModule
    {
//        private static readonly ILog m_log =
//            LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);
        
        private Scene m_scene;
        private IAssetService m_assetService;

        private bool m_Enabled = false;

        // TODO: Change this to a config option
        private string m_RedirectURL = null;

        private string m_URL;

        #region ISharedRegionModule Members

        public void Initialise(IConfigSource source)
        {
            IConfig config = source.Configs["ClientStack.LindenCaps"];
            if (config == null)
                return;

            m_URL = config.GetString("Cap_GetTexture", string.Empty);
            // Cap doesn't exist
            if (m_URL != string.Empty)
            {
                m_Enabled = true;
                m_RedirectURL = config.GetString("GetTextureRedirectURL");
            }
        }

        public void AddRegion(Scene s)
        {
            if (!m_Enabled)
                return;

            m_scene = s;
        }

        public void RemoveRegion(Scene s)
        {
            if (!m_Enabled)
                return;

            m_scene.EventManager.OnRegisterCaps -= RegisterCaps;
            m_scene = null;
        }

        public void RegionLoaded(Scene s)
        {
            if (!m_Enabled)
                return;

            m_assetService = m_scene.RequestModuleInterface<IAssetService>();
            m_scene.EventManager.OnRegisterCaps += RegisterCaps;
        }

        public void PostInitialise()
        {
        }

        public void Close() { }

        public string Name { get { return "GetTextureModule"; } }

        public Type ReplaceableInterface
        {
            get { return null; }
        }

        #endregion

        public void RegisterCaps(UUID agentID, Caps caps)
        {
            UUID capID = UUID.Random();

            //caps.RegisterHandler("GetTexture", new StreamHandler("GET", "/CAPS/" + capID, ProcessGetTexture));
            if (m_URL == "localhost")
            {
//                m_log.DebugFormat("[GETTEXTURE]: /CAPS/{0} in region {1}", capID, m_scene.RegionInfo.RegionName);
                caps.RegisterHandler(
                    "GetTexture",
                    new GetTextureHandler("/CAPS/" + capID + "/", m_assetService, "GetTexture", agentID.ToString(), m_RedirectURL));
            }
            else
            {
//                m_log.DebugFormat("[GETTEXTURE]: {0} in region {1}", m_URL, m_scene.RegionInfo.RegionName);
                IExternalCapsModule handler = m_scene.RequestModuleInterface<IExternalCapsModule>();
                if (handler != null)
                    handler.RegisterExternalUserCapsHandler(agentID,caps,"GetTexture", m_URL);
                else
                    caps.RegisterHandler("GetTexture", m_URL);
            }
        }

    }
}
