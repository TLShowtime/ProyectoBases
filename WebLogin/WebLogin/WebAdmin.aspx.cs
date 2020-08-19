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

    }

    protected void btnPendientes_Click(object sender, EventArgs e)
    {
        Response.Redirect("WebRecibosPendientes.aspx");
    }

    protected void btnPagados_Click(object sender, EventArgs e)
    {
        Response.Redirect("WebPagoRecibos.aspx");
    }

}