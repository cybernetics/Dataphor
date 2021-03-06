<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://ndoc.sf.net/doc"
	exclude-result-prefixes="doc"
>
	<!--
	 | Identity Template
	 +-->

	<xsl:template match="node()|@*" mode="slashdoc">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="slashdoc" />
		</xsl:copy>
	</xsl:template>

	<!--
	 | Block Tags
	 +-->

	<doc:template>
		<summary>A normal paragraph. This ends up being a <b>para</b> tag.</summary>
	</doc:template>

	<xsl:template match="para" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfpara.htm">
		<para>
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</para>
	</xsl:template>
	
  <xsl:template match="p" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfpara.htm">
		<para>
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</para>
	</xsl:template>


	<doc:template>
		<summary>Use the lang attribute to indicate that the text of the
		paragraph is only appropriate for a specific language.</summary>
	</doc:template>

	<xsl:template match="para[@lang]" mode="slashdoc" doc:group="block">
		<note role="lang">
            <title>
				<xsl:text>[</xsl:text>
				<xsl:call-template name="get-lang">
					<xsl:with-param name="lang" select="@lang" />
				</xsl:call-template>
				<xsl:text>]</xsl:text>
            </title>
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</note>
	</xsl:template>

	<doc:template>
		<summary>Multiple lines of code.</summary>
	</doc:template>

	<xsl:template match="code" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfcode.htm">
		<programlisting>
			<xsl:apply-templates mode="slashdoc" />
		</programlisting>
	</xsl:template>

	<doc:template>
		<summary>Use the lang attribute to indicate that the code
		sample is only appropriate for a specific language.</summary>
	</doc:template>

	<xsl:template match="code[@lang]" mode="slashdoc" doc:group="block">
        <para role="lang">
            <xsl:text>[</xsl:text>
            <xsl:call-template name="get-lang">
                <xsl:with-param name="lang" select="@lang" />
            </xsl:call-template>
            <xsl:text>]</xsl:text>
        </para>
		<programlisting>
			<xsl:apply-templates mode="slashdoc" />
		</programlisting>
	</xsl:template>

	<doc:template>
		<summary>See <a href="ms-help://MS.NETFrameworkSDK/cpref/html/frlrfSystemXmlXmlDocumentClassLoadTopic.htm">XmlDocument.Load</a>
		for an example of a note.</summary>
	</doc:template>

	<xsl:template match="note" mode="slashdoc" doc:group="block">
		<note>
            <title>
                <xsl:choose>
                    <xsl:when test="@type='caution'">
                        <b>CAUTION</b>
                    </xsl:when>
                    <xsl:when test="@type='inheritinfo'">
                        <b>Notes to Inheritors: </b>
                    </xsl:when>
                    <xsl:when test="@type='inotes'">
                        <b>Notes to Implementers: </b>
                    </xsl:when>
                    <xsl:otherwise>
                        <b>Note</b>
                    </xsl:otherwise>
                </xsl:choose>
            </title>
			<xsl:apply-templates mode="slashdoc" />
		</note>
	</xsl:template>

	<xsl:template match="list[@type='bullet']" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<itemizedlist mark="disc">
			<xsl:apply-templates select="item" mode="slashdoc" />
		</itemizedlist>
	</xsl:template>

	<xsl:template match="list[@type='bullet']/item" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<listitem>
            <para>
			 <xsl:apply-templates select="./node()" mode="slashdoc" />
            </para>
		</listitem>
	</xsl:template>

	<xsl:template match="list[@type='bullet']/item/term" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<emphasis role="bold"><xsl:apply-templates select="./node()" mode="slashdoc" /> - </emphasis>
	</xsl:template>

	<xsl:template match="list[@type='bullet']/item/description" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<xsl:apply-templates select="./node()" mode="slashdoc" />
	</xsl:template>

	<xsl:template match="list[@type='number']" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<orderedlist>
			<xsl:apply-templates select="item" mode="slashdoc" />
		</orderedlist>
	</xsl:template>

	<xsl:template match="list[@type='number']/item" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<listitem>
            <para>
			 <xsl:apply-templates select="./node()" mode="slashdoc" />
            </para>
		</listitem>
	</xsl:template>

	<xsl:template match="list[@type='number']/item/term" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<emphasis role="bold"><xsl:apply-templates select="./node()" mode="slashdoc" /> - </emphasis>
	</xsl:template>

	<xsl:template match="list[@type='number']/item/description" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<xsl:apply-templates select="./node()" mode="slashdoc" />
	</xsl:template>

	<xsl:template match="list[@type='table']" mode="slashdoc" doc:group="block" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<informaltable>
			<tgroup cols="2">
                  <colspec colnum="1" colname="col1" colwidth="*"/>
                  <colspec colnum="2" colname="col2" colwidth="*"/>
				<xsl:apply-templates select="listheader" mode="slashdoc" />
                <tbody>
				<xsl:apply-templates select="item" mode="slashdoc" />
                </tbody>
			</tgroup>
		</informaltable>
	</xsl:template>

	<xsl:template match="list[@type='table']/listheader" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
        <thead>
            <row>
                <xsl:apply-templates mode="slashdoc" />
            </row>
        </thead>
	</xsl:template>

	<xsl:template match="list[@type='table']/listheader/term" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<entry colname="col1">
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</entry>
	</xsl:template>

	<xsl:template match="list[@type='table']/listheader/description" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<entry colname="col2">
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</entry>
	</xsl:template>

	<xsl:template match="list[@type='table']/item" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<row>
			<xsl:apply-templates mode="slashdoc" />
		</row>
	</xsl:template>

	<xsl:template match="list[@type='table']/item/term" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<entry colname="col1">
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</entry>
	</xsl:template>

	<xsl:template match="list[@type='table']/item/description" mode="slashdoc" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrflist.htm">
		<entry colname="col2">
			<xsl:apply-templates select="./node()" mode="slashdoc" />
		</entry>
	</xsl:template>

	<!--
	 | Inline Tags
	 +-->

	<xsl:template match="c" mode="slashdoc" doc:group="inline" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfc.htm">
		<symbol>
			<xsl:apply-templates mode="slashdoc" />
		</symbol>
	</xsl:template>

	<xsl:template match="paramref[@name]" mode="slashdoc" doc:group="inline" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfparamref.htm">
		<parameter>
			<xsl:value-of select="@name" />
		</parameter>
	</xsl:template>

	<xsl:template match="see[@cref]" mode="slashdoc" doc:group="inline" doc:msdn="ms-help://MS.NETFrameworkSDK/csref/html/vclrfsee.htm">
        <!-- todo: make this work with cref, name refs, usually human generated -->
        <xsl:choose>
            <xsl:when test="@name">
                <ulink>
                    <xsl:attribute name="url">
                        <xsl:call-template name="get-filename-for-cref">
                            <xsl:with-param name="cref" select="@cref"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    <xsl:value-of select="@name"/>
                </ulink>
            </xsl:when>
            <xsl:otherwise>
                <ulink>
                    <xsl:attribute name="url">
                        <xsl:call-template name="get-filename-for-cref">
                            <xsl:with-param name="cref" select="@cref"/>
                        </xsl:call-template>
                    </xsl:attribute>
					<xsl:call-template name="get-a-name">
						<xsl:with-param name="cref" select="@cref" />
					</xsl:call-template>
                </ulink>
            </xsl:otherwise>
        </xsl:choose>
	</xsl:template>

	<xsl:template match="see[@href]" mode="slashdoc" doc:group="inline">
		<ulink url="{@href}">
			<xsl:choose>
				<xsl:when test="node()">
					<xsl:value-of select="." />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@href" />
				</xsl:otherwise>
			</xsl:choose>
		</ulink>
	</xsl:template>

	<xsl:template match="see[@langword]" mode="slashdoc" doc:group="inline">
		<xsl:choose>
			<xsl:when test="@langword='null'">
				<xsl:text>a null reference (</xsl:text>
				<emphasis role="bold">Nothing</emphasis>
				<xsl:text> in Visual Basic)</xsl:text>
			</xsl:when>
			<xsl:when test="@langword='sealed'">
				<xsl:text>sealed (</xsl:text>
				<emphasis role="bold">NotInheritable</emphasis>
				<xsl:text> in Visual Basic)</xsl:text>
			</xsl:when>
			<xsl:when test="@langword='static'">
				<xsl:text>static (</xsl:text>
				<emphasis role="bold">Shared</emphasis>
				<xsl:text> in Visual Basic)</xsl:text>
			</xsl:when>
			<xsl:when test="@langword='abstract'">
				<xsl:text>abstract (</xsl:text>
				<emphasis role="bold">MustInherit</emphasis>
				<xsl:text> in Visual Basic)</xsl:text>
			</xsl:when>
			<xsl:when test="@langword='virtual'">
				<xsl:text>virtual (</xsl:text>
				<emphasis role="bold">CanOverride</emphasis>
				<xsl:text> in Visual Basic)</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<emphasis role="bold">
					<xsl:value-of select="@langword" />
				</emphasis>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>