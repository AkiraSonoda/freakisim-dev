using System;
namespace OpenSim.Modules.Currency {
    public class ClientLogout {
        public String avatarUUID { get; set; }
        public String sessionId { get; set; }
        public String secureSessionId { get; set; }
    }
}
