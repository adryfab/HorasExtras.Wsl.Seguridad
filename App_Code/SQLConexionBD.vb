Imports Microsoft.VisualBasic
Imports System.Data.SqlClient
Imports System.Web
Imports System.Security.Cryptography
Imports System.Text
Imports System.Data

Public Class SQLConexionBD
    Private Conexion As SqlConnection

    Public Sub New()
        Dim strConnString As String = GetConnectionStringByName("ConString")
        Conexion = New SqlConnection(strConnString)
        Try
            Conexion.Open()
        Catch ex As Exception
            Throw ex
        Finally
            Conexion.Close()
        End Try
    End Sub

    Private Function GetConnectionStringByName(ByVal name As String) As String
        ' Assume failure
        Dim returnValue As String = Nothing

        ' Look for the name in the connectionStrings section.
        Dim settings As ConnectionStringSettings = ConfigurationManager.ConnectionStrings(name)

        ' If found, return the connection string.
        If Not settings Is Nothing Then
            returnValue = settings.ConnectionString
        End If

        Dim respuesta As String = Convertir(returnValue)
        returnValue = respuesta

        Return returnValue
    End Function

    Private Function Convertir(ByVal texto As String) As String
        Dim substrings() As String = texto.Split(";")
        Dim subs As String = ""

        Dim passText As String = "password"
        For Each fern As String In substrings
            Console.WriteLine(fern)
            If fern.Contains(passText) = True Then
                Dim pass As String = fern.Substring(9)
                Dim newPass As String = Salida(pass)
                Dim passw As String = "password=" + newPass
                subs = subs + ";" + passw
                Continue For
            End If
            subs = subs + ";" + fern
        Next

        Return subs
    End Function

    Private Function Salida(ByVal Input As String) As String
        Dim IV() As Byte = ASCIIEncoding.ASCII.GetBytes("loterias") 'Debe ser de 8 caracteres
        Dim EncryptionKey() As Byte = Convert.FromBase64String("aprPSvIvLVztmcrlUP/96cG7jky71L5S") 'No se puede alterar la cantidad de caracteres
        Dim buffer() As Byte = Convert.FromBase64String(Input)
        Dim des As TripleDESCryptoServiceProvider = New TripleDESCryptoServiceProvider
        des.Key = EncryptionKey
        des.IV = IV
        Return Encoding.UTF8.GetString(des.CreateDecryptor().TransformFinalBlock(buffer, 0, buffer.Length()))
    End Function

    Public Function RecuperarDatosBiometricoPorUsuario(ByVal user As String) As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spBiometricoPeriodoVigenteRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function GrabarRegisto(ByVal user As String, ByVal infoXml As String) As Integer
        Dim HorasExtrasId As Integer
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spHorasExtrasAgregar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@InfoXml", SqlDbType.Xml))
            SQLDataAdapter.SelectCommand.Parameters("@InfoXml").Value = infoXml
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@HorasExtrasId", SqlDbType.BigInt))
            SQLDataAdapter.SelectCommand.Parameters("@HorasExtrasId").Direction = ParameterDirection.Output
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            SQLDataAdapter.SelectCommand.ExecuteNonQuery()
            HorasExtrasId = SQLDataAdapter.SelectCommand.Parameters("@HorasExtrasId").Value
        Catch ex As Exception
            HorasExtrasId = 0
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return HorasExtrasId
    End Function

    Public Function GrabarAprobacion(ByVal infoXml As String) As Integer
        Dim resultado As Integer
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spAprobacionesActualizar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@InfoXml", SqlDbType.Xml))
            SQLDataAdapter.SelectCommand.Parameters("@InfoXml").Value = infoXml
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            resultado = SQLDataAdapter.SelectCommand.ExecuteNonQuery()
        Catch ex As Exception
            resultado = 0
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return resultado
    End Function

    Public Function EliminarRegistro(ByVal user As String, ByVal infoXml As String) As Integer
        Dim resultado As Integer
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spHorasExtrasEliminar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@InfoXml", SqlDbType.Xml))
            SQLDataAdapter.SelectCommand.Parameters("@InfoXml").Value = infoXml
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            resultado = SQLDataAdapter.SelectCommand.ExecuteNonQuery()
        Catch ex As Exception
            resultado = 0
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return resultado
    End Function

    Public Function RecuperarAprobaciones(ByVal user As String) As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spAprobacionesRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function RecuperarDatosEmpleado(ByVal user As String) As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spDatosEmpleadoRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function ValidarJustificacion(ByVal user As String) As Boolean
        Dim validado As Boolean = False
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spJustifcacionValidar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@Justificado", SqlDbType.Bit))
            SQLDataAdapter.SelectCommand.Parameters("@Justificado").Direction = ParameterDirection.Output
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            SQLDataAdapter.SelectCommand.ExecuteNonQuery()
            validado = SQLDataAdapter.SelectCommand.Parameters("@Justificado").Value
        Catch ex As Exception
            validado = False
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return validado
    End Function

    Public Function RecuperarImprimir(ByVal user As String) As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spImprimirRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function RecuperarProcesar() As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spProcesarRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function TotalesProcesar() As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spProcesarTotales", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

    Public Function ValidarFeriados(ByVal fecha As Date, ByVal localidad As Int32) As Boolean
        Dim validado As Boolean = False
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spFeriadosValidar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@fecha", SqlDbType.Date))
            SQLDataAdapter.SelectCommand.Parameters("@fecha").Value = fecha
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@localidad", SqlDbType.Int))
            SQLDataAdapter.SelectCommand.Parameters("@localidad").Value = localidad
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@feriado", SqlDbType.Bit))
            SQLDataAdapter.SelectCommand.Parameters("@feriado").Direction = ParameterDirection.Output
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            SQLDataAdapter.SelectCommand.ExecuteNonQuery()
            validado = SQLDataAdapter.SelectCommand.Parameters("@feriado").Value
        Catch ex As Exception
            validado = False
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return validado
    End Function

    Public Function ActualizarTotales(ByVal user As String, ByVal infoXml As String) As Integer
        Dim resultado As Integer
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spTotalesActualizar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@InfoXml", SqlDbType.Xml))
            SQLDataAdapter.SelectCommand.Parameters("@InfoXml").Value = infoXml
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            resultado = SQLDataAdapter.SelectCommand.ExecuteNonQuery()
        Catch ex As Exception
            resultado = 0
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return resultado
    End Function

    Public Function MenuAprobar(ByVal user As String) As Boolean
        Dim validado As Boolean = False
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spUsuarioAprobador", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@Aprobador", SqlDbType.Bit))
            SQLDataAdapter.SelectCommand.Parameters("@Aprobador").Direction = ParameterDirection.Output
            If Conexion.State = ConnectionState.Closed Then
                Conexion.Open()
            End If
            SQLDataAdapter.SelectCommand.ExecuteNonQuery()
            validado = SQLDataAdapter.SelectCommand.Parameters("@Aprobador").Value

        Catch ex As Exception
            validado = False
        Finally
            If Conexion.State = ConnectionState.Open Then
                Conexion.Close()
            End If
        End Try
        Return validado
    End Function

    Public Function RecuperarAtrasos(ByVal user As String) As DataSet
        Dim dtSet = New DataSet
        Try
            Dim SQLDataAdapter = New SqlDataAdapter("spAtrasosRecuperar", Conexion)
            SQLDataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure
            SQLDataAdapter.SelectCommand.Parameters.Add(New SqlParameter("@UsuarioId", SqlDbType.VarChar, 50))
            SQLDataAdapter.SelectCommand.Parameters("@UsuarioId").Value = user
            SQLDataAdapter.Fill(dtSet)
        Catch ex As Exception
            dtSet = Nothing
        End Try
        Return dtSet
    End Function

End Class
