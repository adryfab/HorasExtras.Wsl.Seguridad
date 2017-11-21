Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols

' Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://www.loteria.com.ec/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class Seguridad
    Inherits System.Web.Services.WebService

    Private adAuth As LdapAuthentication = New LdapAuthentication("LDAP://")

    <WebMethod()> _
    Public Function ValidarCredenciales(ByRef usuario As String, ByVal clave As String, ByVal dominio As String, _
                                        ByRef CodEmp As String, ByRef NomEmp As String) As Boolean
        Dim resultado As Boolean = adAuth.ValidarCredenciales(usuario, clave, dominio)
        usuario = adAuth.Usuario
        CodEmp = adAuth.CodEmp
        NomEmp = adAuth.NomEmp
        Return resultado
    End Function

    <WebMethod()> _
    Public Function MenuProcesar(ByVal UArea As String, ByVal UDep As String, ByVal UCargo As String) As Boolean
        Dim resultado As Boolean = adAuth.MenuProcesar(UArea, UDep, UCargo)
        Return resultado
    End Function

End Class