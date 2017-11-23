Imports Microsoft.VisualBasic
Imports System.Text
Imports System.Collections
Imports System.DirectoryServices

Public Class LdapAuthentication
    Dim _path As String
    Dim _filterAttribute As String

    Private _Usuario As String
    Public Property Usuario() As String
        Get
            Return _Usuario
        End Get
        Set(value As String)
            _Usuario = value
        End Set
    End Property

    Private _CodEmp As String
    Public Property CodEmp() As String
        Get
            Return _CodEmp
        End Get
        Set(value As String)
            _CodEmp = value
        End Set
    End Property

    Private _NomEmp As String
    Public Property NomEmp() As String
        Get
            Return _NomEmp
        End Get
        Set(value As String)
            _NomEmp = value
        End Set
    End Property

    Public Sub New(ByVal path As String)
        _path = path
    End Sub

    Public Function IsAuthenticated(ByVal domain As String, ByVal username As String, ByVal pwd As String, ByVal sesion As String, ByVal empId As String) As Boolean
        Dim domainAndUsername As String = domain & "\" & username
        Dim entry As DirectoryEntry = New DirectoryEntry(_path, domainAndUsername, pwd)

        Try
            'Bind to the native AdsObject to force authentication.
            Dim obj As Object = entry.NativeObject
            Dim search As DirectorySearcher = New DirectorySearcher(entry)

            search.Filter = "(" & sesion & "=" & username & ")"
            search.PropertiesToLoad.Add("cn")
            search.PropertiesToLoad.Add("sAMAccountName")
            search.PropertiesToLoad.Add("postalCode")
            Dim result As SearchResult = search.FindOne()

            If (result Is Nothing) Then
                Return False
            End If

            'Update the new path to the user in the directory.
            _path = result.Path
            _filterAttribute = CType(result.Properties("cn")(0), String)
            Usuario = CType(result.Properties("sAMAccountName")(0), String)
            CodEmp = CType(result.Properties("postalCode")(0), String)
            NomEmp = CType(result.Properties("cn")(0), String)
        Catch ex As Exception
            Throw New Exception("Error de autenticación de usuario. " & ex.Message)
        End Try

        Return True
    End Function

    Public Function GetGroups() As String
        Dim search As DirectorySearcher = New DirectorySearcher(_path)
        search.Filter = "(cn=" & _filterAttribute & ")"
        search.PropertiesToLoad.Add("memberOf")
        Dim groupNames As StringBuilder = New StringBuilder()

        Try
            Dim result As SearchResult = search.FindOne()
            Dim propertyCount As Integer = result.Properties("memberOf").Count

            Dim dn As String
            Dim equalsIndex, commaIndex As Object

            Dim propertyCounter As Integer

            For propertyCounter = 0 To propertyCount - 1
                dn = CType(result.Properties("memberOf")(propertyCounter), String)

                equalsIndex = dn.IndexOf("=", 1)
                commaIndex = dn.IndexOf(",", 1)
                If (equalsIndex = -1) Then
                    Return Nothing
                End If

                groupNames.Append(dn.Substring((equalsIndex + 1), (commaIndex - equalsIndex) - 1))
                groupNames.Append("|")
            Next

        Catch ex As Exception
            Throw New Exception("Error al obtener nombres del grupo. " & ex.Message)
        End Try

        Return groupNames.ToString()
    End Function

    Private Function ValidarLogin(ByVal usuario As String, ByVal clave As String, ByRef dominio As String) As SearchResult
        Dim entry As New DirectoryEntry
        Dim str As String = dominio
        Dim path As String = ("LDAP://" & str)
        Dim str4 As String = usuario
        Dim str2 As String = clave
        entry = New DirectoryEntry(path, (str & "\" & usuario), clave, AuthenticationTypes.Secure)
        Try
            Dim searcher As New DirectorySearcher
            searcher.SearchRoot = entry
            searcher.Filter = ("(&(objectClass=user)(sAMAccountName=" & usuario & "))")

            searcher.PropertiesToLoad.Add("cn")
            searcher.PropertiesToLoad.Add("sAMAccountName")
            searcher.PropertiesToLoad.Add("postalCode")

            searcher.SearchScope = SearchScope.Subtree
            Dim result2 As SearchResult = searcher.FindOne
            If (Not result2 Is Nothing) Then
                'Update the new path to the user in the directory.
                _path = result2.Path
                _filterAttribute = CType(result2.Properties("cn")(0), String)
                usuario = CType(result2.Properties("sAMAccountName")(0), String)
                NomEmp = CType(result2.Properties("cn")(0), String)
                If result2.Properties("postalCode").Count > 0 Then
                    CodEmp = CType(result2.Properties("postalCode")(0), String)
                Else
                    Throw New System.ArgumentException("No existe el codigo del usuario", "postalCode")
                End If

                Return result2
                End If
        Catch ex As Exception
            Throw ex
        End Try
        Return Nothing
    End Function

    Public Function ValidarCredenciales(ByVal usuario As String, ByVal clave As String, ByVal dominio As String) As Boolean
        Dim flag2 As Boolean = False
        flag2 = (Not ValidarLogin(usuario, clave, (dominio)).GetDirectoryEntry Is Nothing)
        If Not flag2 Then
            Return False
        End If
        Return flag2
    End Function

    Public Function MenuProcesar(ByVal UArea As String, ByVal UDep As String, ByVal UCargo As String) As Boolean
        Dim retorno As Boolean = False
        Dim rootWebConfig1 As System.Configuration.Configuration
        rootWebConfig1 = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~/")
        If (0 < rootWebConfig1.AppSettings.Settings.Count) Then
            Dim Area, Departamento, Cargo As System.Configuration.KeyValueConfigurationElement
            Area = rootWebConfig1.AppSettings.Settings("Area")
            Departamento = rootWebConfig1.AppSettings.Settings("Departamento")
            Cargo = rootWebConfig1.AppSettings.Settings("Cargo")
            If Area.Value = UArea And Departamento.Value = UDep And Cargo.Value = UCargo Then
                retorno = True
            Else
                retorno = False
            End If
        End If
        Return retorno
    End Function

End Class
