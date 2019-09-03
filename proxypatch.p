--- ipxe/src/net/proxy.c	1969-12-31 16:00:00.000000000 -0800
+++ ipxepatch/src/net/proxy.c	2019-08-14 10:17:29.941214925 -0700
@@ -0,0 +1,70 @@
+#include <string.h>
+#include <ipxe/proxy.h>
+#include <ipxe/uri.h>
+#include <ipxe/settings.h>
+
+/** @file
+ *
+ * HTTP Proxy
+ *
+ */
+
+FILE_LICENCE ( GPL2_OR_LATER );
+
+struct uri *proxy_uri = NULL;
+
+/** HTTP proxy address setting */
+struct setting http_proxy_setting __setting ( SETTING_MISC, "" ) = {
+	.name = "http-proxy",
+	.description = "Address and port of the HTTP (not HTTPS) proxy to use, as a http scheme URI",
+	.type = &setting_type_string,
+};
+
+int is_proxy_set ( ) {
+	/* Later, this may be expanded to encompass other settings */
+	if ( ! proxy_uri ) {
+		proxy_uri = get_proxy();
+	}
+	return ! ! proxy_uri;
+}
+
+struct uri *get_proxy ( ) {
+	char *http_proxy_unexpanded, *http_proxy;
+
+	if ( setting_exists ( NULL, &http_proxy_setting ) && ! proxy_uri ) {
+		/* Later, this may select from multiple settings*/
+		fetch_string_setting_copy ( NULL, &http_proxy_setting, &http_proxy_unexpanded );
+		http_proxy = expand_settings ( http_proxy_unexpanded );
+		proxy_uri = parse_uri ( http_proxy );
+		free ( http_proxy_unexpanded );
+		free ( http_proxy );
+		/* Only the http scheme is currently supported */
+		if ( strcmp ( proxy_uri->scheme, "http" ) != 0 ) {
+			uri_put ( proxy_uri );
+			DBG ( "http-proxy must begin with \"http://\"" );
+			return NULL;
+		}
+	}
+
+	return proxy_uri;
+}
+
+const char *proxied_uri_host ( struct uri *uri ) {
+	/* Later, this could select from multiple proxies,
+	based on hostname patterns matched against the uri */
+	if ( is_proxy_set ( ) ) {
+		return proxy_uri->host;
+	} else {
+		return uri->host;
+	}
+}
+
+unsigned int proxied_uri_port ( struct uri *uri, unsigned int default_port ) {
+	/* Later, this could select from multiple proxies,
+	based on hostname patterns matched against the uri */
+	if ( is_proxy_set ( ) ) {
+		return uri_port ( proxy_uri, default_port);
+	} else {
+		return uri_port ( uri, default_port);
+	}
+}
--- ipxe/src/net/tcp/httpconn.c	2019-09-03 09:36:53.142934857 -0700
+++ ipxepatch/src/net/tcp/httpconn.c	2019-08-14 10:23:02.155235061 -0700
@@ -41,6 +41,7 @@
 #include <ipxe/open.h>
 #include <ipxe/pool.h>
 #include <ipxe/http.h>
+#include <ipxe/proxy.h>
 
 /** HTTP pooled connection expiry time */
 #define HTTP_CONN_EXPIRY ( 10 * TICKS_PER_SEC )
@@ -250,7 +251,9 @@
 		return -EINVAL;
 
 	/* Identify port */
-	port = uri_port ( uri, scheme->port );
+	/* port = uri_port ( uri, scheme->port ); */
+
+        port = proxied_uri_port ( uri, scheme->port );
 
 	/* Look for a reusable connection in the pool.  Reuse the most
 	 * recent connection in order to accommodate authentication
@@ -302,7 +305,8 @@
 		goto err_filter;
 	if ( ( rc = xfer_open_named_socket ( socket, SOCK_STREAM,
 					     ( struct sockaddr * ) &server,
-					     uri->host, NULL ) ) != 0 )
+					     /* uri->host, NULL ) ) != 0 ) */
+	                                     proxied_uri_host ( uri ), NULL ) ) != 0 )
 		goto err_open;
 
 	/* Attach to parent interface, mortalise self, and return */
--- ipxe/src/net/tcp/httpcore.c	2019-09-03 09:36:53.142934857 -0700
+++ ipxepatch/src/net/tcp/httpcore.c	2019-08-14 10:17:29.945214937 -0700
@@ -57,6 +57,7 @@
 #include <ipxe/vsprintf.h>
 #include <ipxe/errortab.h>
 #include <ipxe/http.h>
+#include <ipxe/proxy.h>
 
 /* Disambiguate the various error causes */
 #define EACCES_401 __einfo_error ( EINFO_EACCES_401 )
@@ -599,8 +600,14 @@
 
 	/* Calculate request URI length */
 	memset ( &request_uri, 0, sizeof ( request_uri ) );
-	request_uri.path = ( uri->path ? uri->path : "/" );
-	request_uri.query = uri->query;
+	if ( is_proxy_set ( ) ) {
+	  /*include all fields*/
+	  memcpy( &request_uri, uri, sizeof( request_uri ));
+	}
+	else {
+	  request_uri.path = ( uri->path ? uri->path : "/" );
+	  request_uri.query = uri->query;
+	}
 	request_uri_len =
 		( format_uri ( &request_uri, NULL, 0 ) + 1 /* NUL */);
 
--- ipxe/src/include/ipxe/proxy.h	1969-12-31 16:00:00.000000000 -0800
+++ ipxepatch/src/include/ipxe/proxy.h	2019-08-14 10:17:17.622178690 -0700
@@ -0,0 +1,17 @@
+#ifndef _IPXE_PROXY_H
+#define _IPXE_PROXY_H
+
+/** @file
+ *
+ * HTTP Proxy
+ *
+ */
+
+FILE_LICENCE ( GPL2_OR_LATER );
+
+int is_proxy_set ( );
+struct uri *get_proxy ( );
+const char *proxied_uri_host ( struct uri *uri );
+unsigned int proxied_uri_port ( struct uri *uri, unsigned int default_port );
+
+#endif /* _IPXE_PROXY_H */
--- ipxe/src/include/ipxe/settings.h	2019-09-03 09:36:53.114934233 -0700
+++ ipxepatch/src/include/ipxe/settings.h	2019-08-14 10:17:17.623178693 -0700
@@ -467,6 +467,8 @@
 mac_setting __setting ( SETTING_NETDEV, mac );
 extern const struct setting
 busid_setting __setting ( SETTING_NETDEV, busid );
+extern struct setting
+http_proxy_setting __setting ( SETTING_MISC, ip );
 extern const struct setting
 user_class_setting __setting ( SETTING_HOST_EXTRA, user-class );
 extern const struct setting
