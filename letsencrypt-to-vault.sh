#!/bin/bash

process_args() {
    # Default
    VAULT_TOKEN="$VAULT_TOKEN"
    VAULT_ADDR="$VAULT_ADDR"
    VAULT_CERT_PATH="certs"

    while [[ $# -gt 0 ]]
    do
        key="$1"

        case $key in
            -h|--help)
            show_help
            exit 0
            ;;
            -t|--vault-token)
            VAULT_TOKEN="$2"
            shift
            ;;
            -a|--vault-addr)
            VAULT_ADDR="$2"
            shift
            ;;
            -p|--vault-cert-path)
            VAULT_CERT_PATH="$2"
            shift
            ;;
            *)
            echo "Unknown flag: $2"
            exit 1
            ;;
        esac
    done
}

show_help() {
    echo "Let's encrypt to Hashicorp Vault"
    echo
    echo "Renew or get Let's Encrypt certificates and send it to Hashicorp Vault" 
    echo
    echo "Usage:"
}

cert_renew() {
    echo
}

send_to_vault() { 
    local certs_dir="/etc/letsencrypt/live"

    for sitename in $(find $certs_dir -maxdepth 1 -mindepth 1 -type d -exec basename {} \;)
    do
        local privkey=$(cat $certs_dir/$sitename/cert.pem)
        local cert=$(cat $certs_dir/$sitename/privkey.pem)

        curl \
            -H "X-Vault-Token: $VAULT_TOKEN" \
            -H "Content-Type: application/json" \
            -X POST \
            -d "{\"key\":\"$privkey\", \"cert\": \"$cert\"}" \
            "http://$VAULT_ADDR/v1/secret/$VAULT_CERT_PATH/$sitename"
    done
}

main() {
    process_args $@
    cert_renew
    send_to_vault
}

main $@
