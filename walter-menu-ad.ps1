#!/bin/bash

# ==========================================
# CONFIGURACIÓN DEL DOMINIO OPENLDAP
# ==========================================
DOMINIO="dc=walter2026,dc=ldap"
USUARIO_ADMIN="cn=admin,$DOMINIO"

# ==========================================
# FUNCIONES
# ==========================================

# Pedir contraseña del administrador
pedir_clave() {
    echo "Contraseña de admin LDAP:"
    read -s admin_pass
    echo ""
}

# Opción 1: Eliminar correo de un usuario
eliminar_correo() {
    echo ""
    echo "--- ELIMINAR CORREO DE UN USUARIO ---"
    echo "UID del usuario (ej: walteralu1):"
    read uid_user
    echo "Unidad Organizativa (Alumnado/Profesorado):"
    read ou_user
    pedir_clave

    # Escribimos el archivo LDIF temporal
    echo "dn: cn=${uid_user},ou=${ou_user},${DOMINIO}" > del_mail.ldif
    echo "changetype: modify" >> del_mail.ldif
    echo "delete: mail" >> del_mail.ldif

    # Modificamos usando el archivo -f y luego lo borramos
    ldapmodify -x -D "$USUARIO_ADMIN" -w "$admin_pass" -f del_mail.ldif
    rm -f del_mail.ldif
}

# Opción 2: Modificar correo de un usuario
modificar_correo() {
    echo ""
    echo "--- MODIFICAR CORREO DE UN USUARIO ---"
    echo "UID del usuario (ej: walteralu2):"
    read uid_user
    echo "Unidad Organizativa (Alumnado/Profesorado):"
    read ou_user
    echo "Nuevo correo:"
    read nuevo_mail
    pedir_clave

    # Generación del archivo LDIF temporal para la modificación
    echo "dn: cn=${uid_user},ou=${ou_user},${DOMINIO}" > mod_mail.ldif
    echo "changetype: modify" >> mod_mail.ldif
    echo "replace: mail" >> mod_mail.ldif
    echo "mail: ${nuevo_mail}" >> mod_mail.ldif

    # Modificamos usando el archivo -f y luego lo borramos
    ldapmodify -x -D "$USUARIO_ADMIN" -w "$admin_pass" -f mod_mail.ldif
    rm -f mod_mail.ldif
}

# Opción 3a: Buscar un usuario concreto
buscar_usuario() {
    echo "UID del usuario a buscar:"
    read busca_uid
    echo ""
    ldapsearch -x -b "$DOMINIO" "(uid=$busca_uid)"
}

# Opción 3b: Listar todos los usuarios
listar_usuarios() {
    echo ""
    echo "=== LISTADO DE USUARIOS (NOMBRE Y CORREO) ==="
    ldapsearch -x -b "$DOMINIO" "(objectClass=inetOrgPerson)" cn mail
}

# ==========================================
# MENÚ PRINCIPAL (BUCLE)
# ==========================================
while true; do
    echo "=========================================="
    echo "    MENÚ DE GESTIÓN OPENLDAP - WALTER"
    echo "=========================================="
    echo "1. Eliminar correo de un usuario"
    echo "2. Modificar correo de un usuario"
    echo "3. Realizar búsquedas (Usuario o Listado)"
    echo "4. Salir"
    echo "=========================================="
    echo "Seleccione una opción [1-4]:"
    read opcion

    case "$opcion" in
        1)
            eliminar_correo
            echo "Presione Enter para continuar..."
            read pausa
            ;;
        2)
            modificar_correo
            echo "Presione Enter para continuar..."
            read pausa
            ;;
        3)
            echo ""
            echo "a) Buscar un usuario concreto"
            echo "b) Listar TODOS los usuarios"
            echo "Seleccione subopción [a/b]:"
            read subopcion

            if [ "$subopcion" = "a" ]; then
                buscar_usuario
            elif [ "$subopcion" = "b" ]; then
                listar_usuarios
            else
                echo "Opción no válida."
            fi
            echo "Presione Enter para continuar..."
            read pausa
            ;;
        4)
            echo "Saliendo del script..."
            exit
            ;;
        *)
            echo "Opción no válida, intente de nuevo."
            read pausa
            ;;
    esac
done