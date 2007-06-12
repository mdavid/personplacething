<?xml version="1.0"?>
<xsl:transform version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:func="http://atomictalk.org/function"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:enc="clitype:System.Text.UTF8Encoding?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:string="clitype:System.String?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:hmacsha1="clitype:System.Security.Cryptography.HMACSHA1?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:convert="clitype:System.Convert?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:s3response="clitype:Extf.Net.S3.Response?from=file:///srv/wwwroot/webapp/bin/Extf.Net.dll"
    xmlns:aws-conn="clitype:Extf.Net.S3.AWSAuthConnection?from=file:///srv/wwwroot/webapp/bin/Extf.Net.dll"
    xmlns:aws-gen="clitype:Extf.Net.S3.QueryStringAuthGenerator?from=file:///srv/wwwroot/webapp/bin/Extf.Net.dll"
    xmlns:http-util="clitype:System.Web.HttpUtility?from=file:///usr/lib/mono/2.0/System.Web.dll"
    xmlns:s3object="clitype:Extf.Net.S3.S3Object?from=file:///srv/wwwroot/webapp/bin/Extf.Net.dll"
    xmlns:sortedlist="clitype:System.Collections.SortedList?from=file:///usr/lib/mono/2.0/mscorlib.dll"
    xmlns:clitype="http://saxon.sf.net/clitype"
    xmlns:aws="http://xameleon.org/function/aws"
    exclude-result-prefixes="xs func enc hmacsha1 clitype sortedlist saxon string convert s3response aws-conn aws-gen s3object">

  <xsl:param name="aws-public-key"/>
  <xsl:param name="aws-private-key"/>
  <xsl:variable name="issecure" select="false()" as="xs:boolean"/>
  <xsl:variable name="aws-gen" select="aws-gen:new($aws-public-key, $aws-private-key, $issecure)"/>
  <xsl:variable name="aws-conn" select="aws-conn:new($aws-public-key, $aws-private-key, $issecure)"/>
  <xsl:variable name="expires-in" select="aws:s3-set-expires-in($aws-gen, 60000)"/>
  <xsl:variable name="not-set" select="'not-set'" as="xs:string"/>

  <xsl:function name="aws:s3-normalize-key">
    <xsl:param name="folder"/>
    <xsl:param name="key"/>
    <xsl:value-of select="concat(if (not(ends-with($folder, '/'))) then concat($folder, '/') else $folder, $key)"/>
  </xsl:function>

  <xsl:function name="aws:s3-list-bucket">
    <xsl:param name="bucket" />
    <xsl:param name="prefix" />
    <xsl:param name="marker" />
    <xsl:param name="maxKeys" as="xs:integer"/>
    <xsl:param name="delimiter" />
    <xsl:value-of
        select="if ($expires-in) then aws-gen:listBucket($aws-gen, $bucket, $prefix, $marker, $maxKeys) else $not-set"/>
  </xsl:function>

  <xsl:function name="aws:s3-set-expires-in">
    <xsl:param name="aws-auth-gen"/>
    <xsl:param name="expires-in"/>
    <xsl:value-of 
        select="aws-gen:set_ExpiresIn($aws-gen, $expires-in)"/>
  </xsl:function>

  <xsl:function name="aws:s3-get-signature">
    <xsl:param name="bucket" as="xs:string"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="aws-public-key"/>
    <xsl:param name="aws-private-key"/>
    <xsl:param name="issecure" as="xs:boolean"/>
    <xsl:value-of
        select="if ($expires-in) then http-util:UrlDecode(aws-gen:get($aws-gen, $bucket, $key)) else $not-set"/>
  </xsl:function>

  <xsl:function name="aws:s3-get-signature">
    <xsl:param name="bucket" as="xs:string"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="issecure" as="xs:boolean"/>
    <xsl:variable name="aws-gen" select="aws-gen:new($aws-public-key, $aws-private-key, $issecure)"/>
    <xsl:value-of
        select="http-util:UrlDecode(aws-gen:get($aws-gen, $bucket, $key))"/>
  </xsl:function>

  <xsl:function name="aws:s3-put-object">
    <xsl:param name="bucket" as="xs:string"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="object"/>
    <xsl:param name="pubkey"/>
    <xsl:param name="privkey"/>
    <xsl:param name="issecure" as="xs:boolean"/>
    <xsl:variable name="s3Object" select="s3object:new($object)"/>
    <xsl:value-of
        select="s3response:getResponseMessage(aws-conn:put($aws-conn, $bucket, $key, $s3Object))"/>
  </xsl:function>
  
  <xsl:function name="aws:s3-get-object">
    <xsl:param name="bucket" as="xs:string"/>
    <xsl:param name="key" as="xs:string"/>
    <xsl:value-of
        select="s3response:getResponseMessage(aws-conn:get($aws-conn, $bucket, $key))"/>
  </xsl:function>

  <xsl:function name="aws:s3-create-bucket">
    <xsl:param name="publicKey" as="xs:string"/>
    <xsl:param name="privateKey" as="xs:string"/>
    <xsl:param name="issecure" as="xs:boolean"/>
    <xsl:param name="bucket" as="xs:string"/>
    <xsl:value-of
        select="s3response:getResponseMessage(aws-conn:createBucket($aws-conn, $bucket))"/>
  </xsl:function>

</xsl:transform>

