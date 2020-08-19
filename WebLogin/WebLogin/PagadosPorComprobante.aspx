<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PagadosPorComprobante.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 547px;
        }
        .auto-style2 {
            width: 694px;
        }
        .auto-style3 {
            margin-left: 89px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="background-color: #00FFFF; background-image: url('ruinasFondoPaginas.jpg'); background-repeat: no-repeat; background-attachment: scroll; background-position: left top; border-style: groove; width: auto; height: 960px; text-align: center; font-family: 'Gloucester MT Extra Condensed'; font-size: large; font-weight: 300;">
            <table style="width: 100%; text-align: center; font-family: 'Gloucester MT Extra Condensed'; font-size: large; font-weight: 500; color: #FFFFFF;">
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td class="auto-style2">Recibos pagados por Comprobante:</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td class="auto-style2">&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td class="auto-style2">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" BackColor="#666666" BorderColor="White" BorderStyle="Dashed" CssClass="auto-style3" ForeColor="White" Height="298px" Width="589px">
                            <Columns>
                                <asp:BoundField DataField="Nombre" HeaderText="Nombre Tarifa" SortExpression="Nombre" InsertVisible="False" ReadOnly="True" />
                                <asp:BoundField DataField="Monto" HeaderText="Monto" SortExpression="Monto" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="Data Source=.;Initial Catalog=Empresa;Integrated Security=True" ProviderName="System.Data.SqlClient" SelectCommand="SELECT DISTINCT CT.Nombre,D.Monto FROM dbo.Detalle D inner join dbo.ConceptoTarifa CT on D.IdConceptoTarifa = CT.Id inner join dbo.Factura F on D.IdFactura = F.Id inner join dbo.Contrato C on F.IdContrato = F.IdContrato where C.NumeroTelefono = '+ Convert.ToString(Session[&quot;Telefono&quot;])+' and F.Id = + Convert.ToString(Session[&quot;IdFactura&quot;])"></asp:SqlDataSource>
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
