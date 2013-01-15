using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;

namespace ChatterService
{
    public class ProfilesServices : IProfilesServices
    {
        #region IProfilesServices Members

        public string GetEmployeeId(string nodeId)
        {
            System.Text.StringBuilder sql = new System.Text.StringBuilder();
            string employeeId = null;

            string connstr = ConfigurationManager.ConnectionStrings["ChatterService.Properties.Settings.profilesConnectionString"].ConnectionString;

            sql.AppendLine("select p.internalusername from [Profile.Data].[Person] p join [RDF.Stage].internalnodemap i on p.personid = i.internalid where i.[class] = 'http://xmlns.com/foaf/0.1/Person' and i.nodeid = " + nodeId);

            SqlConnection dbconnection = new SqlConnection(connstr);
            SqlCommand dbcommand = new SqlCommand();

            SqlDataReader dbreader;
            dbconnection.Open();
            dbcommand.CommandType = CommandType.Text;

            dbcommand.CommandText = sql.ToString();
            dbcommand.CommandTimeout = 5000;

            dbcommand.Connection = dbconnection;

            dbreader = dbcommand.ExecuteReader(CommandBehavior.CloseConnection);

            while (dbreader.Read())
            {
                employeeId = dbreader[0].ToString();
            }

            if (!dbreader.IsClosed)
                dbreader.Close();


            return employeeId;
        }

        #endregion
    }
}
