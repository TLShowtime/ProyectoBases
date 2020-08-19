using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        SqlDataSource1.SelectCommand = "SELECT F.Id,F.MontoTotalAPagar,F.FechaPago FROM dbo.Factura F inner join dbo.Contrato C on F.IdContrato = C.Id AND C.NumeroTelefono = '" + Convert.ToString(Session["Telefono"]) + "' WHERE F.Estado = 0 AND F.Activo = 1";
        SqlDataSource1.DataBind();
    }

    protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
    {
        int numeroFactura = Convert.ToInt32(GridView1.SelectedRow.Cells[1].Text);
        Session["IdFactura"] = numeroFactura;
        Response.Redirect("PagadosPorComprobante.aspx");
    }
}