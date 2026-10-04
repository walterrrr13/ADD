#!/bin/bash

# Configuración del dominio OpenLDAP
SUFFIX="dc=walter2026,dc=ldap"
BINDDN="cn=admin,$SUFFIX"

while true; do
    echo "=========================================="
    echo "    MENÚ DE GESTIÓN OPENLDAP - WALTER"
    echo "=========================================="
    echo "1. Eliminar correo de un usuario"
    echo "2. Modificar correo de un usuario"
    echo "3. Realizar búsquedas (Usuario o Listado)"
    echo "4. Salir"
    echo "=========================================="
    read -p "Seleccione una opción [1-4]: " opcion

    case $opcion in
        1)
            echo ""
            echo "--- ELIMINAR CORREO DE UN USUARIO ---"
            read -p "Introduzca el UID del usuario (ej: walteralu1): " uid_user
            read -p "Unidad Organizativa [Alumnado/Profesorado]: " ou_user
            read -sp "Contraseña de admin LDAP: " admin_pass
            echo ""

            # Creación del archivo temporal LDIF para borrar el atributo mail
            cat << LDIF_DEL > /tmp/del_mail.ldif
dn: cn=${uid_user},ou=${ou_user},${SUFFIX}
changetype: modify
delete: mail
LDIF_DEL

            ldapmodify -x -D "$BINDDN" -w "$admin_pass" -f /tmp/del_mail.ldif
            rm -f /tmp/del_mail.ldif
            echo ""
            read -p "Presione Enter para continuar..."
            ;;

        2)
            echo ""
            echo "--- MODIFICAR CORREO DE UN USUARIO ---"
            read -p "Introduzca el UID del usuario (ej: walteralu2): " uid_user
            read -p "Unidad Organizativa [Alumnado/Profesorado]: " ou_user
            read -p "Nuevo correo electrónico: " nuevo_mail
            read -sp "Contraseña de admin LDAP: " admin_pass
            echo ""

            # Creación del archivo temporal LDIF para reemplazar/añadir el atributo mail
            cat << LDIF_MOD > /tmp/mod_mail.ldif
dn: cn=${uid_user},ou=${ou_user},${SUFFIX}
changetype: modify
replace: mail
mail: ${nuevo_mail}
LDIF_MOD

            ldapmodify -x -D "$BINDDN" -w "$admin_pass" -f /tmp/mod_mail.ldif
            rm -f /tmp/mod_mail.ldif
            echo ""
            read -p "Presione Enter para continuar..."
            ;;

        3)
            echo ""
            echo "--- BÚSQUEDAS EN LDAP ---"
            echo "a) Consultar un usuario concreto"
            echo "b) Listar TODOS los usuarios (solo Nombre y Correo)"
            read -p "Seleccione subopción [a/b]: " subopc

            if [ "$subopc" = "a" ]; then
                read -p "Introduzca el UID del usuario a buscar: " busca_uid
                echo ""
                ldapsearch -x -b "$SUFFIX" "(uid=$busca_uid)"
            elif [ "$subopc" = "b" ]; then
                echo ""
                echo "=== LISTADO DE USUARIOS (NOMBRE Y CORREO) ==="
                ldapsearch -x -b "$SUFFIX" "(objectClass=inetOrgPerson)" cn mail
            else
                echo "Subopción no válida."
            fi
            echo ""
            read -p "Presione Enter para continuar..."
            ;;

        4)
            echo "Saliendo del script..."
            exit 0
            ;;

        *)
            echo "Opción no válida."
            sleep 1
            ;;
    esac
done
EOF