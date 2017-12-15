using System;
namespace OpenSim.Modules.Currency {
    public class UserInfo {
        public String avatarUUID { get; set; }
        public String avatarName { get; set; }
        public String simAddress { get; set; }
        public String sessionId { get; set; }
        public String secureSessionId { get; set; }
        public String password { get; set; }
        public String token { get; set; }
    }
}
