<%@ Page Language="C#" AutoEventWireup="true" CodeFile="login.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Empresa Z - Post Pago</title>
    <style type="text/css">
        .auto-style4 {
            width: 1572px;
            height: 980px;
        }
        .auto-style7 {
            height: 26px;
            width: 320px;
        }
        .auto-style13 {
            margin-top: 0px;
        }
        .auto-style14 {
            height: 552px;
            width: 364px;
            margin-left: 670px;
        }
        .auto-style15 {
            width: 89%;
            height: 400px;
            margin-left: 118px;
        }
        .auto-style16 {
            height: 39px;
            width: 320px;
        }
        .auto-style17 {
            height: 63px;
            width: 320px;
        }
        .auto-style18 {
            margin-left: 0px;
        }
        .auto-style19 {
            height: 84px;
            width: 320px;
        }
        .auto-style20 {
            height: 41px;
            width: 320px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="auto-style4" style="border-style: double; background-position: left top; background-image: url('ruinas.jpg'); background-repeat: no-repeat; background-attachment: scroll; font-family: Arial; font-size: 12px; font-weight: normal; font-style: normal; font-variant: normal; color: #000000; width: auto; height: 960px; background-color: #00FFFF;">
            <br /><br />  
                <div class="auto-style14">
                <table style="border-style: groove; font-family: 'Gill Sans MT'; font-size: large; font-weight: 300; font-style: normal; background-color: #808080; color: #000000; font-variant: normal; text-align: center; background-image: url('fondoinicio.png');" class="auto-style15">
                    <tr>
                        <td class="auto-style20">
                            Ingrese un teléfono:</td>
                    </tr>
                    <tr>
                        <td class="auto-style16">
            <asp:Label ID="Label3" runat="server" Text="Telefono"></asp:Label>  
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox ID="txtTelefono" runat="server" BackColor="#999999" BorderColor="White" BorderStyle="Groove" CssClass="auto-style18" Font-Size="Smaller" Font-Underline="False" Height="25px" Width="116px">                                             </asp:TextBox>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="auto-style17">
                <asp:Button ID="Button1" runat="server" Text="Aceptar" OnClick="Button1_Click" Width="127px" BackColor="#CCCCCC" BorderStyle="Groove" Font-Names="Franklin Gothic Demi" Font-Size="Medium" ForeColor="Black" />
                        </td>
                    </tr>
                    <tr>
                        <td class="auto-style19">
                            <asp:Label ID="lblLogin" runat="server"></asp:Label>
                        </td>
                    </tr>
            </table>
            </div>
                <br />
            <br />
            <br />
            <br />
            <br />
            <br /><br />   
            <asp:Panel ID="Panel1" runat="server" CssClass="auto-style13">
            </asp:Panel>
            <asp:Panel ID="Panel2" runat="server">
            </asp:Panel>
        </div>
    </form>
</body>
</html>
