using System;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Xml;
using System.Xml.Linq;
using Microsoft.SqlServer.Server;

namespace ChatterService
{
    public class ChatterSqlProcedures
    {

        public ChatterSqlProcedures()
        {
        }


        [SqlProcedure]
        public static void CreateActivity(SqlString url, SqlString username, SqlString password, SqlString token, SqlString employeeId, SqlXml messageBlob, SqlInt32 pmid, SqlString articleTitle, SqlString journalTitle)
        {
            IChatterSoapService service = new ChatterSoapService(url.Value);
            service.AllowUntrustedConnection();
            service.Login(username.Value, password.Value, token.Value);

            XElement xml = XElement.Parse(messageBlob.Value);
            CreateProfileActivity(service, employeeId.Value, xml);
            if (!pmid.IsNull)
            {
                // was this added manually or my disambiguation?
                if (GetElementValue(xml, "{http://ns.opensocial.org/2008/opensocial}title").Contains("added"))
                {
                    CreateExternalMessage(service, employeeId.Value, pmid.Value, articleTitle.Value, 
                        "just added a new publiction in UCSF Profiles :" + articleTitle.Value + " " + journalTitle.Value);
                }
                else
                {
                    CreateExternalMessage(service, employeeId.Value, pmid.Value, articleTitle.Value, 
                        "has a new publication listed in UCSF Profiles :" + articleTitle.Value + " " + journalTitle.Value);
                }
            }
        }

        protected static void CreateProfileActivity(IChatterSoapService service, string employeeId, XElement element)
        {
            String code = GetElementValue(element, "{http://ns.opensocial.org/2008/opensocial}title");
            String body = GetElementValue(element, "{http://ns.opensocial.org/2008/opensocial}body", code);


            String postedTimeStr = GetElementValue(element, "{http://ns.opensocial.org/2008/opensocial}postedTime"); ;
            DateTime postedTime = ConvertUnixEpochTime(postedTimeStr);

            service.CreateProfileActivity(employeeId, code, body, postedTime);
        }

        public static string GetElementValue(XElement element, string name)
        {
            XElement elem = element.Element(name);
            if (elem == null)
            {
                throw new Exception("Element " + name + " was not found");
            }
            return elem.Value;
        }

        public static string GetElementValue(XElement element, string name, string defaultValue)
        {
            XElement elem = element.Element(name);
            if (elem == null)
            {
                return defaultValue;
            }
            return string.IsNullOrEmpty(elem.Value) ? defaultValue : elem.Value;
        }

        public static DateTime ConvertUnixEpochTime(string milliseconds)
        {
            try {
                double ml = Double.Parse(milliseconds);
                DateTime dt = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
                return dt.ToLocalTime().AddMilliseconds(ml);
            }
            catch(Exception ex) {
                throw new Exception("Incorrect time format:" + milliseconds, ex);
            }
        }

        protected static void CreateExternalMessage(IChatterSoapService service, string employeeId, int pmid, string title, string body)
        {
            service.CreateExternalMessage("http://www.ncbi.nlm.nih.gov/pubmed/" + pmid, title, body, employeeId);
        }

    }
}
