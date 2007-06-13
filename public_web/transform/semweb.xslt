<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:at="http://atomictalk.org"
    xmlns:func="http://atomictalk.org/function"
    xmlns:aspnet="http://atomictalk.org/function/aspnet"
    xmlns:aspnet-session="clitype:System.Web.SessionState.HttpSessionState?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-server="clitype:System.Web.HttpServerUtility?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-request="clitype:System.Web.HttpRequest?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-response="clitype:System.Web.HttpResponse?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-timestamp="clitype:System.DateTime?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:request-collection="clitype:Xameleon.Function.HttpRequestCollection?from=file:///srv/wwwroot/webapp/bin/Xameleon.dll"
    xmlns:response-collection="clitype:Xameleon.Function.HttpResponseCollection?from=file:///srv/wwwroot/webapp/bin/Xameleon.dll"
    xmlns:xameleon-semweb="clitype:Xameleon.SemWeb.Select?from=file:///srv/wwwroot/webapp/bin/Xameleon.dll"
    xmlns:semweb="http://xameleon.org/service/semweb"
    xmlns:service="http://xameleon.org/service"
    xmlns:operation="http://xameleon.org/service/operation"
    xmlns:session="http://xameleon.org/service/session"
    xmlns:param="http://xameleon.org/service/session/param"
    xmlns:header="http://xameleon.org/service/http/header"
    xmlns:metadata="http://xameleon.org/service/metadata"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:clitype="http://saxon.sf.net/clitype"
    exclude-result-prefixes="at aspnet aspnet-timestamp aspnet-server aspnet-session aspnet-request aspnet-response saxon metadata header param service operation session semweb func xs xsi fn clitype response-collection request-collection xameleon-semweb">

  <xsl:param name="response" />
  <xsl:param name="request"/>
  <xsl:param name="server"/>
  <xsl:param name="session"/>
  <xsl:param name="timestamp"/>
  <xsl:variable name="debug"
      select=" if (request-collection:GetValue($request, 'query-string', 'debug') = 'true') then true() else false()"
      as="xs:boolean" />
  <xsl:variable name="session-params" select="/service:operation/param:*"/>

  <xsl:strip-space elements="*"/>

  <xsl:template match="service:operation">
    <xsl:param name="key-name"/>
    <xsl:variable name="issecure" select="false()" as="xs:boolean"/>
    <xsl:variable name="content-type" select="
      if ($debug) 
      then aspnet:response.set-content-type($response, 'text/plain') 
      else aspnet:response.set-content-type($response, 'text/xml')"/>
    <message type="service:result" content-type="{if (empty($content-type)) then aspnet:response.get-content-type($response) else 'not-set'}">
      <xsl:apply-templates/>
    </message>
  </xsl:template>

  <xsl:template match="operation:*">
    <operation type="{local-name()}">
      <xsl:apply-templates />
    </operation>
  </xsl:template>

  <xsl:template match="semweb:select">
    <xsl:variable name="uri" select="func:resolve-variable(@uri)"/>
    <select uri="{$uri}">
      <result>
        <xsl:apply-templates>
          <xsl:with-param name="uri" select="$uri"/>
        </xsl:apply-templates>
      </result>
    </select>
  </xsl:template>

  <xsl:template match="semweb:process">
    <xsl:param name="uri"/>
    <xsl:value-of select="xameleon-semweb:Process($uri)" disable-output-escaping="yes"/>
  </xsl:template>

</xsl:transform>

