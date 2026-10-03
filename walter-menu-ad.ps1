# Cargar el modulo de Active Directory
Import-Module ActiveDirectory

# Guardar el nombre base del dominio (DC=walter,DC=aws)
$dominio = (Get-ADDomain).DistinguishedName

do {
    # 1) Mostrar el menu
    Write-Host "1. Informacion del dominio"
    Write-Host "2. Crear OU"
    Write-Host "3. Crear grupo"
    Write-Host "4. Crear usuario"
    Write-Host "5. Salir"

    # 2) Leer la opcion
    $opcion = Read-Host "Elige una opcion"

    # 3) Segun la opcion, hacer una cosa u otra
    switch ($opcion) {
        "1" {
            # Opcion 1: Informacion del dominio
            Write-Host "Nombre del equipo: $env:COMPUTERNAME"
            Write-Host "Nombre del dominio: $((Get-ADDomain).DNSRoot)"
            Write-Host "Numero de OUs: $((Get-ADOrganizationalUnit -Filter *).Count)"
            Write-Host "Numero de grupos: $((Get-ADGroup -Filter *).Count)"
            Write-Host "Numero de usuarios: $((Get-ADUser -Filter *).Count)"
        }
        "2" {
            # Opcion 2: Crear OU
            $nombreOU = Read-Host "Nombre de la nueva OU"
            New-ADOrganizationalUnit -Name $nombreOU
            Write-Host "OU creada correctamente"
        }
        "3" {
            # Opcion 3: Crear grupo
            $nombreGrupo = Read-Host "Nombre del grupo"
            $ou = Read-Host "Nombre de la OU donde se creara"
            $ruta = "OU=$ou,$dominio"
            New-ADGroup -Name $nombreGrupo -GroupScope Global -Path $ruta
            Write-Host "Grupo creado correctamente"
        }
        "4" {
            # Opcion 4: Crear usuario
            $nombre = Read-Host "Nombre"
            $apellido = Read-Host "Apellido"
            $username = Read-Host "Nombre de usuario (login)"
            $ou = Read-Host "OU donde ira el usuario"
            $grupo = Read-Host "Grupo al que se agregara"
            $clave = Read-Host "Contrasena inicial" -AsSecureString

            $ruta = "OU=$ou,$dominio"
            $upn = "$username@$((Get-ADDomain).DNSRoot)"

            New-ADUser -Name "$nombre$apellido" `
                       -SamAccountName $username `
                       -UserPrincipalName $upn `
                       -Path $ruta `
                       -AccountPassword $clave `
                       -Enabled $true `
                       -ChangePasswordAtLogon $true

            Add-ADGroupMember -Identity $grupo -Members $username
            Write-Host "Usuario creado e introducido en el grupo correctamente"
        }
        "5" {
            Write-Host "Adios"
        }
        default {
            Write-Host "Opcion no valida"
        }
    }
} while ($opcion -ne "5")