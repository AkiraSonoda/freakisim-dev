using System;
namespace OpenSim.Modules.Currency {
    public class Transfer {
        public String senderID { get; set; }
        public String senderSessionID { get; set; }
        public String senderSecureSessionID { get; set; }
        public String description { get; set; }
        public String objectID { get; set; }
        public String receiverID { get; set; }
        public String regionHandle { get; set; }
        public int transactionType { get; set; }
        public int amount { get; set; }
    }
}
