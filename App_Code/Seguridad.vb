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

    '<WebMethod()> _
    'Public Function HelloWorld() As String
    '    Return "Hola a todos"
    'End Function

    <WebMethod()> _
    Public Function ValidarCredenciales(ByVal usuario As String, ByVal clave As String, ByVal dominio As String) As Boolean
        Dim adAuth As LdapAuthentication = New LdapAuthentication("LDAP://")
        Dim resultado As Boolean = adAuth.ValidarCredenciales(usuario, clave, dominio)
        Return resultado
    End Function
End Class