<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:at="http://atomictalk.org"
    xmlns:func="http://atomictalk.org/function"
    xmlns:sortedlist="clitype:System.Collections.SortedList?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:aspnet="http://atomictalk.org/function/aspnet"
    xmlns:aspnet-session="clitype:System.Web.SessionState.HttpSessionState?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-server="clitype:System.Web.HttpServerUtility?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-request="clitype:System.Web.HttpRequest?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-response="clitype:System.Web.HttpResponse?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:aspnet-timestamp="clitype:System.DateTime?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:request-collection="clitype:Xameleon.Function.HttpRequestCollection?from=file:///srv/wwwroot/webapp/bin/Xameleon.dll"
    xmlns:response-collection="clitype:Xameleon.Function.HttpResponseCollection?from=file:///srv/wwwroot/webapp/bin/Xameleon.dll"
    xmlns:service="http://xameleon.org/service"
    xmlns:operation="http://xameleon.org/service/operation"
    xmlns:session="http://xameleon.org/service/session"
    xmlns:param="http://xameleon.org/service/session/param"
    xmlns:aws="http://xameleon.org/function/aws"
    xmlns:s3="http://xameleon.org/function/aws/s3"
    xmlns:header="http://xameleon.org/service/http/header"
    xmlns:metadata="http://xameleon.org/service/metadata"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:clitype="http://saxon.sf.net/clitype"
    xmlns:amazonaws="http://s3.amazonaws.com/doc/2006-03-01/"
    exclude-result-prefixes="amazonaws at aspnet aspnet-timestamp aspnet-server aspnet-session aspnet-request aspnet-response saxon metadata header sortedlist param service operation session aws s3 func xs xsi fn clitype response-collection request-collection">

  <xsl:import href="file:///srv/wwwroot/sonicradar.com/transform/functions/amazonaws/funcset-s3.xslt"/>

  <xsl:param name="aws-public-key" select="'not-set'" as="xs:string"/>
  <xsl:param name="aws-private-key" select="'not-set'" as="xs:string"/>
  <xsl:param name="response" />
  <xsl:param name="request"/>
  <xsl:param name="server"/>
  <xsl:param name="session"/>
  <xsl:param name="timestamp"/>
  <xsl:variable name="debug" select="if (request-collection:GetValue($request, 'query-string', 'debug') = 'true') then true() else false()" as="xs:boolean" />
  <xsl:variable name="guid" select="request-collection:GetValue($request, 'cookie', 'guid')" as="xs:string" />
  <xsl:variable name="session-params" select="/service:operation/param:*"/>
  <xsl:variable name="s3-bucket-name" select="$session-params[local-name() = 's3-bucket-name']" />

  <xsl:strip-space elements="*"/>

  <xsl:template match="header:*">
    <xsl:param name="sorted-list" as="clitype:System.Collections.SortedList"/>
    <xsl:variable name="key" select="local-name() cast as xs:untypedAtomic"/>
    <xsl:variable name="value" select=". cast as xs:untypedAtomic"/>
    <xsl:value-of select="sortedlist:Add($sorted-list, $key, $value)"/>
  </xsl:template>

  <xsl:template match="service:operation">
    <xsl:param name="key-name"/>
    <xsl:variable name="issecure" select="false()" as="xs:boolean"/>
    <xsl:variable name="content-type">
      <xsl:choose>
        <xsl:when test="not($debug)">
          <xsl:value-of select="aspnet:response.set-content-type($response, 'text/xml')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="aspnet:response.set-content-type($response, 'text/html')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="/transform/openid-redirect.xsl"</xsl:text>
    </xsl:processing-instruction>
    <auth status="session">
      <url>
        <xsl:value-of select="request-collection:GetValue($request, 'query-string', 'return_uri')"/>
      </url>
      <message>
        <xsl:sequence select="$content-type"/>
        <xsl:apply-templates />
        <xsl:if test="$debug">
          <HttpRequest>
            <RawUrl>
              <xsl:sequence select="aspnet-request:RawUrl($request)" />
            </RawUrl>
            <Cookies>
              <guid>
                <xsl:sequence select="$guid"/>
              </guid>
            </Cookies>
          </HttpRequest>
          <!-- <Operation>
            <FileName>
              <xsl:value-of select="$key-name"/>
            </FileName>
            <S3PutObject>
              <xsl:value-of
                  select="aws:s3-put-object($s3-bucket-name, $key-name, $guid, $aws-public-key, $aws-private-key, $issecure)"/>
            </S3PutObject>
            <S3GetSignature>
              <xsl:value-of
                  select="if (unparsed-text-available(aws:s3-get-signature($s3-bucket-name, $key-name, $issecure))) then 'hello' else 'failed!'"/>
            </S3GetSignature>
            <S3GetSignature>
            <xsl:value-of
                select="unparsed-text(aws:s3-get-signature($s3-bucket-name, $key-name, $issecure))"/>
              <xsl:value-of select="aws:s3-get-signature($s3-bucket-name, $key-name, $issecure)"/>
            </S3GetSignature>
            <S3GetObject>
              <xsl:copy-of
                  select="document('http://s3.amazonaws.com/m.david/screen-shots/VS.NET_on_MacOSX.foo')/*"/>
            </S3GetObject>
            <S3ListBucket>
              <xsl:variable name="bucket" select="aws:s3-list-bucket($s3-bucket-name, $key-name, '', 1 cast as xs:integer, '/')"/>
              <xsl:value-of select="encode-for-uri('/')"/>
              <xsl:copy-of
                  select="document($bucket)/*"/>
            </S3ListBucket>
          </Operation>
          <HttpResponse>
            <ContentType>
              <xsl:value-of select="$content-type"/>
            </ContentType>
            <TimeStamp>
              <xsl:value-of select="func:get-timestamp($timestamp, 'short-time')"/>
            </TimeStamp>
          </HttpResponse> -->
        </xsl:if>
      </message>
    </auth>
  </xsl:template>

  <xsl:template match="operation:aws">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="aws:s3">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="s3:check-for-existing-key">
    <xsl:variable name="folder-name" select="func:resolve-variable(@folder)"/>
    <xsl:variable name="file-name" select="func:resolve-variable(@file)"/>
    <xsl:variable name="key-name" select="aws:s3-normalize-key($folder-name, $file-name)"/>
    <xsl:variable name="key-uri" select="aws:s3-get-signature($s3-bucket-name, $key-name, $issecure)"/>
    <xsl:apply-templates select="if (aws:s3-key-exists($key-uri)) then at:IfTrue else at:IfFalse">
      <xsl:with-param name="key-name" select="$key-name"/>
      <xsl:with-param name="key-uri" select="$key-uri"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:function name="aws:s3-key-exists" as="xs:boolean">
    <xsl:param name="key-uri"/>
    <xsl:sequence select="unparsed-text-available($key-uri)"/>
  </xsl:function>

  <xsl:template match="at:IfFalse">
  <xsl:param name="key-name"/>
    <xsl:sequence
        select="aws:s3-put-object($s3-bucket-name, $key-name, $guid, $aws-public-key, $aws-private-key, $issecure)"/>
  </xsl:template>

  <xsl:template match="at:IfTrue">
    <xsl:param name="key-uri"/>
    <xsl:variable name="params">
      <xsl:apply-templates select="param:*" mode="eval">
        <xsl:with-param name="key-uri" select="$key-uri"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="key-uri" select="$key-uri"/>
      <xsl:with-param name="params" select="$params"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="param:*" mode="eval">
    <xsl:param name="key-uri"/>
    <xsl:element name="{local-name()}">
      <xsl:apply-templates>
        <xsl:with-param name="key-uri" select="$key-uri"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>

  <xsl:template match="at:compare">
    <xsl:param name="key-uri"/>
    <xsl:param name="params"/>
<!--     <xsl:sequence select="$params/*[local-name() = 'key-value']"/> -->
  </xsl:template>

  <xsl:template match="s3:return-file-content">
    <xsl:param name="key-uri"/>
    <xsl:sequence select="unparsed-text($key-uri)"/>
  </xsl:template>
  
  <xsl:template match="s3:write-file">
    <xsl:param name="key-name"/>
    <xsl:variable name="file-content" select="func:resolve-variable(@content)"/>
    <xsl:sequence select="aws:s3-put-object($s3-bucket-name, $key-name, $file-content, $aws-public-key, $aws-private-key, $issecure)"/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:sequence select="normalize-space(.)"/>
  </xsl:template>

</xsl:transform>

