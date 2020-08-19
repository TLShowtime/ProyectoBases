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
        SqlDataSource1.SelectCommand = "SELECT DISTINCT CT.Nombre,D.Monto FROM dbo.Detalle D inner join dbo.ConceptoTarifa CT on D.IdConceptoTarifa = CT.Id inner join dbo.Factura F on D.IdFactura = F.Id inner join dbo.Contrato C on F.IdContrato = F.IdContrato where C.NumeroTelefono = '"+  Convert.ToString(Session["Telefono"])  + "' and F.Id ="  + (int)Session["IdFactura"];
        SqlDataSource1.DataBind();
    }
}