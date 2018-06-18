using System;
namespace OpenSim.Modules.Currency {
    public class Balance {
        public String avatarUUID { get; set; }
        public int balance { get; set; }
        public int status { get; set; }
    }
}
