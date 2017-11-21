Imports System.Web
Imports System.Web.Services
Imports System.Web.Services.Protocols
Imports System.Data

' Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente.
' <System.Web.Script.Services.ScriptService()> _
<WebService(Namespace:="http://www.loteria.com.ec/")> _
<WebServiceBinding(ConformsTo:=WsiProfiles.BasicProfile1_1)> _
<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Public Class Seguridad
    Inherits System.Web.Services.WebService

    Private adAuth As LdapAuthentication = New LdapAuthentication("LDAP://")
    Private conn As SQLConexionBD = New SQLConexionBD()

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

    <WebMethod()> _
    Public Function RecuperarDatosBiometricoPorUsuario(ByVal user As String) As DataSet
        Dim dts As DataSet = conn.RecuperarDatosBiometricoPorUsuario(user)
        Return dts
    End Function

    <WebMethod()> _
    Public Function RecuperarDatosEmpleado(ByVal user As String) As DataSet
        Dim dts As DataSet = conn.RecuperarDatosEmpleado(user)
        Return dts
    End Function

    <WebMethod()> _
    Public Function GrabarRegisto(ByVal user As String, ByVal infoXml As String) As Integer
        Dim retorno As Integer = conn.GrabarRegisto(user, infoXml)
        Return retorno
    End Function

    <WebMethod()> _
    Public Function EliminarRegistro(ByVal user As String, ByVal infoXml As String) As Integer
        Dim retorno As Integer = conn.EliminarRegistro(user, infoXml)
        Return retorno
    End Function

    <WebMethod()> _
    Public Function ActualizarTotales(ByVal user As String, ByVal infoXml As String) As Integer
        Dim retorno As Integer = conn.ActualizarTotales(user, infoXml)
        Return retorno
    End Function

    <WebMethod()> _
    Public Function ValidarFeriados(ByVal fecha As Date, ByVal localidad As Int32) As Boolean
        Dim resultado As Boolean = conn.ValidarFeriados(fecha, localidad)
        Return resultado
    End Function

    <WebMethod()> _
    Public Function RecuperarAprobaciones(ByVal user As String) As DataSet
        Dim dts As DataSet = conn.RecuperarAprobaciones(user)
        Return dts
    End Function

    <WebMethod()> _
    Public Function ValidarJustificacion(ByVal user As String) As Boolean
        Dim resultado As Boolean = conn.ValidarJustificacion(user)
        Return resultado
    End Function

    <WebMethod()> _
    Public Function GrabarAprobacion(ByVal infoXml As String) As Integer
        Dim retorno As Integer = conn.GrabarAprobacion(infoXml)
        Return retorno
    End Function

    <WebMethod()> _
    Public Function RecuperarImprimir(ByVal user As String) As DataSet
        Dim dts As DataSet = conn.RecuperarImprimir(user)
        Return dts
    End Function

    <WebMethod()> _
    Public Function RecuperarProcesar() As DataSet
        Dim dts As DataSet = conn.RecuperarProcesar()
        Return dts
    End Function

    <WebMethod()> _
    Public Function TotalesProcesar() As DataSet
        Dim dts As DataSet = conn.TotalesProcesar()
        Return dts
    End Function

End Class