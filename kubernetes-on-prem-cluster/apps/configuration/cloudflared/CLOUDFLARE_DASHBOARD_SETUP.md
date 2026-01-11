# Cloudflare Dashboard Configuration for ArgoCD

Since you've configured cloudflared via the Cloudflare dashboard, here are the settings you need to ensure ArgoCD works properly in browsers:

## Required Settings in Cloudflare Dashboard

### 1. Public Hostname Configuration

In your Cloudflare Tunnel → Public Hostname settings:

- **Subdomain**: `argocd` (or your chosen subdomain)
- **Domain**: Your domain
- **Service**: `https://argocd-server.argocd.svc.cluster.local:443`
- **HTTP Host Header**: `argocd.yourdomain.com` (your actual domain)

### 2. Origin Request Settings

Click "Configure" next to your public hostname and ensure:

- ✅ **No TLS Verify**: Enable this (ArgoCD uses self-signed certs internally)
- ✅ **HTTP Host Header**: Set to `argocd.yourdomain.com`
- ✅ **Origin Server Name**: `argocd-server.argocd.svc.cluster.local`
- ✅ **HTTP/2 Origin**: Enable this (required for WebSocket support)

### 3. Additional Settings

- **Connect Timeout**: 10s
- **TCP Keep Alive**: 30s
- **Keep Alive Connections**: 100

## ArgoCD Server Configuration

You also need to configure ArgoCD server to know about the external URL. Apply the ConfigMap in `04-argocd-server-config.yaml`:

```bash
kubectl apply -f apps/configuration/cloudflared/04-argocd-server-config.yaml
```

Then restart the ArgoCD server:

```bash
kubectl rollout restart deployment argocd-server -n argocd
```

## Common Browser Issues

### Issue: Page loads but UI doesn't work / WebSocket errors

**Solution**: Ensure "HTTP/2 Origin" is enabled in Cloudflare dashboard origin request settings.

### Issue: TLS/SSL errors in browser

**Solution**: Enable "No TLS Verify" in origin request settings.

### Issue: 404 errors or wrong content

**Solution**: Verify the HTTP Host Header matches your domain exactly.

### Issue: CORS errors

**Solution**: Ensure the `url` in ArgoCD ConfigMap matches your public hostname.

## Testing

1. **Test with curl** (should work):
   ```bash
   curl -k https://argocd.yourdomain.com
   ```

2. **Test in browser**:
   - Open `https://argocd.yourdomain.com` in your browser
   - Check browser console (F12) for errors
   - Look for WebSocket connection errors

3. **Check cloudflared logs**:
   ```bash
   kubectl logs -n cloudflared -l pod=cloudflared --tail=50
   ```

## Troubleshooting

If browser still doesn't work after these settings:

1. **Clear browser cache** and try incognito mode
2. **Check browser console** for specific error messages
3. **Verify DNS** - ensure your domain resolves correctly
4. **Check ArgoCD logs**:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server --tail=50
   ```
