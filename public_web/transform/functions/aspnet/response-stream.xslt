<?xml version="1.0"?>
<xsl:transform version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:func="http://atomictalk.org/function"
    xmlns:aspnet="http://atomictalk.org/function/aspnet"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:response-stream="clitype:System.Web.HttpResponse?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:clitype="http://saxon.sf.net/clitype"
    exclude-result-prefixes="xs func clitype saxon response-stream">

  <xsl:function name="aspnet:response.get-buffer-output">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:BufferOutput($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-buffer-output">
    <xsl:param name="response"/>
    <xsl:param name="buffer-output" as="xs:boolean"/>
    <xsl:sequence select="response-stream:set_BufferOutput($response, $buffer-output)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.get-content-encoding">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:ContentEncoding($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-content-encoding">
    <xsl:param name="response"/>
    <xsl:param name="content-encoding" as="xs:string"/>
    <xsl:sequence select="response-stream:set_ContentEncoding($response, $content-encoding)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.get-content-type">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:ContentType($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-content-type">
    <xsl:param name="response"/>
    <xsl:param name="content-type" as="xs:string"/>
    <xsl:sequence select="response-stream:set_ContentType($response, $content-type)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.get-status-code">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:StatusCode($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-status-code">
    <xsl:param name="response"/>
    <xsl:param name="status-code" as="xs:integer"/>
    <xsl:sequence select="response-stream:set_StatusCode($response, $status-code)"/>
  </xsl:function>
  
  <xsl:function name="aspnet:response.set-redirect">
    <xsl:param name="response"/>
    <xsl:param name="location" as="xs:string"/>
    <xsl:sequence select="response-stream:Redirect($response, $location)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.get-redirect-location">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:RedirectLocation($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-redirect-location">
    <xsl:param name="response"/>
    <xsl:param name="location" as="xs:string"/>
    <xsl:sequence select="response-stream:set_RedirectLocation($response, $location)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.get-charset">
    <xsl:param name="response"/>
    <xsl:sequence select="response-stream:Charset($response)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.set-charset">
    <xsl:param name="response"/>
    <xsl:param name="charset" as="xs:string"/>
    <xsl:sequence select="response-stream:set_Charset($response, $charset)"/>
  </xsl:function>

  <xsl:function name="aspnet:response.transmit-file">
    <xsl:param name="response"/>
    <xsl:param name="file" as="xs:string"/>
    <xsl:sequence select="response-stream:TransmitFile($response, $file)"/>
  </xsl:function>

</xsl:transform>
