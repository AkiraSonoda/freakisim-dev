using System;
namespace OpenSim.Modules.Currency {
    public class Transaction {
        public String uuid { get; set; }
        public String sender { get; set; }
        public String receiver { get; set; }
        public int amount { get; set; }
        public String objectuuid { get; set; }
        public String regionhandle { get; set; }
        public int type { get; set; }
        public int time { get; set; }
        public String secure { get; set; }
        public int status { get; set; }
        public String commonname { get; set; }
        public String description { get; set; }
    }
}
