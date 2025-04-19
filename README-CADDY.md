# How to install the Caddy Authority certificate into your browser

## Chrome-based browsers (Chrome, Brave, etc.)

- Go to Settings / Privacy & Security / Security/Manage Certificates / Authorities
- Import [ `./caddy-root-ca-authority.crt` ]
- Check on [ Trust this certificate for identifying websites ]
- Save changes

## Firefox-based browsers

- Go to Settings / Privacy & Security / Security / Certificates / View Certificates / Authorities
- Import [ `./caddy-root-ca-authority.crt` ]
- Check on [ This certificate can identify websites ]
- Save changes

> [!TIP]
>
> For further information, please visit [Caddy Official Documentation](https://caddyserver.com/docs/running#local-https-with-docker)
