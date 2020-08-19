using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using System.Data.SqlClient;

public partial class _Default : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {
       
    }
    protected void Button1_Click(object sender, EventArgs e)
    {
        SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["con"].ToString());
        con.Open();
        SqlCommand cmd = new SqlCommand("SP_Verificar_Telefono", con);
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@inTelefono", SqlDbType.VarChar);
        cmd.Parameters.AddWithValue("@outIdTelefono", SqlDbType.Int).Direction = ParameterDirection.Output;

        cmd.Parameters["@inTelefono"].Value = txtTelefono.Text;

        cmd.ExecuteScalar();

        int login = (int)cmd.Parameters["@outIdTelefono"].Value;
        if (login >= 1)
        {
            lblLogin.Text = "Iniciando sesión...";
            Session["Telefono"] = txtTelefono.Text;
            Session["IdContrato"] = (int)cmd.Parameters["@outIdTelefono"].Value;
            Response.Redirect("WebAdmin.aspx");
        }
        else {
            lblLogin.Text = "Numero no registrado";
        }
        
        con.Close();
    }
}