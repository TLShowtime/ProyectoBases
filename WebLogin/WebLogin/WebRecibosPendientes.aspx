<%@ Page Language="C#" AutoEventWireup="true" CodeFile="WebRecibosPendientes.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        .auto-style1 {
            width: 95px;
        }
        .auto-style2 {
            margin-left: 540px;
            margin-top: 79px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="font-family: 'Gloucester MT Extra Condensed'; font-size: large; font-weight: 500; color: #FFFFFF; text-align: center; background-image: url('ruinasFondoPaginas.jpg'); background-repeat: no-repeat; background-attachment: scroll; background-position: left top; border-style: groove; width: auto; height: 960px">
            <table style="width: 100%; text-align: center;">
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td>Seleccione la factura:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <asp:Label ID="Label1" runat="server"></asp:Label>
                    </td>
                    <td>&nbsp;</td>
                </tr>
                <tr>
                    <td class="auto-style1">&nbsp;</td>
                    <td>
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" OnSelectedIndexChanged="GridView1_SelectedIndexChanged" Width="608px" AllowPaging="True" BackColor="#666666" BorderColor="White" CssClass="auto-style2" ForeColor="White">
                            <Columns>
                                <asp:CommandField ShowSelectButton="True" />
                                <asp:BoundField DataField="Id" HeaderText="Numero" SortExpression="Id" />
                                <asp:BoundField DataField="MontoTotalAPagar" HeaderText="Monto Total A Pagar" SortExpression="MontoTotalAPagar" />
                                <asp:BoundField DataField="FechaPago" HeaderText="Fecha A Pagar" SortExpression="FechaPago" />
                            </Columns>
                        </asp:GridView>
                        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="Data Source=LAPTOP-RCGTG6D0;Initial Catalog=Empresa;Integrated Security=True" ProviderName="System.Data.SqlClient" SelectCommand="SELECT F.Id,F.MontoTotalAPagar,F.FechaPago FROM dbo.Factura F inner join dbo.Contrato C on F.IdContrato =  C.Id AND C.NumeroTelefono = ' + Session[&quot;Telefono&quot;] +'  WHERE F.Estado = 0 AND F.Activo = 1" ></asp:SqlDataSource>
                    </td>
                    <td>&nbsp;</td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
