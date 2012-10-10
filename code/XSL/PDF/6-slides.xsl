<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	version="1.0">


<xsl:template match="COLLECTION">
	<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
                <fo:layout-master-set>
                   <fo:simple-page-master master-name="slides"
		                     page-height="300mm" 
		                     page-width="210mm"
		                     margin-top="20mm" 
		                     margin-bottom="20mm" 
		                     margin-left="20mm" 
                		     margin-right="20mm">
                		 <fo:region-before extent="15mm"/>
				<fo:region-body margin-top="20mm"/>
			</fo:simple-page-master>
	
		</fo:layout-master-set>
		<!--Body dim Width = 170mm Height 225mm-->
		<fo:page-sequence master-reference="slides">
			<fo:static-content flow-name="xsl-region-before">
				<fo:table background-color="rgb(204,204,255)" table-layout="fixed">
				<fo:table-column column-width="15mm"/>
				<fo:table-column column-width="55mm"/>
				<fo:table-column column-width="40mm"/>
				<fo:table-column column-width="60mm"/>
				<fo:table-body>
					<fo:table-row>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(204,204,255)" text-align="center" number-rows-spanned="2">
						<fo:block>
							<fo:external-graphic height="10mm" src="{@ICONSOURCE}"/>
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(204,204,255)">
						<fo:block>
							Tufts University
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(204,204,255)" text-align="end" number-columns-spanned="2">
						<fo:block font-style="italic">
							<xsl:value-of select="@COPYRIGHT"/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
					<fo:table-row>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(204,204,255)" number-columns-spanned="2">
						<fo:block font-size="10pt">
							<xsl:value-of select="@NAME"/> (<xsl:value-of select="@AUTHOR"/>)
						</fo:block>
					</fo:table-cell>
					<fo:table-cell border-width="1mm" border-style="solid" border-color="rgb(204,204,255)" text-align="end">
						<fo:block font-size="10pt">
							Page - <fo:page-number/>
						</fo:block>
					</fo:table-cell>
					</fo:table-row>
				</fo:table-body>
				</fo:table>
			</fo:static-content>
			<fo:flow flow-name="xsl-region-body">
			<fo:table  table-layout="fixed" border-width="2mm" border-style="solid" border-color="rgb(255,255,255)">
				<fo:table-column column-width="7mm"/>
				<fo:table-column column-width="76mm"/>
				<fo:table-column column-width="2mm"/>
				<fo:table-column column-width="7mm"/>
				<fo:table-column column-width="76mm"/>
				<fo:table-body>
<xsl:for-each select="SLIDE">
	<xsl:if test="(position() mod 2) = 1">
		<fo:table-row height="10mm">
		<fo:table-cell>
			<fo:block>
				<xsl:value-of select="position()"/>.
			</fo:block>
		</fo:table-cell>
		<fo:table-cell height="10mm" text-align="center">
			<fo:block>
				<xsl:apply-templates/>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell height="10mm">
		</fo:table-cell>
		<fo:table-cell height="10mm">
			<fo:block>
				<!-- As silly as this looks there is no >= -->
				<xsl:if test="not((position() + 1) &gt; last())">
				<xsl:value-of select="position() + 1"/>.
				</xsl:if>
			</fo:block>
		</fo:table-cell>
		<fo:table-cell height="10mm" text-align="center">
			<fo:block>
				<xsl:if test="not((position() + 1) &gt; last())">
				<xsl:value-of select="following-sibling::SLIDE[1]"/>
				</xsl:if>
			</fo:block>
		</fo:table-cell>
		</fo:table-row>
		<fo:table-row height="74mm" keep-with-previous="always">
		<fo:table-cell number-columns-spanned="2" text-align="center"  border-width="1mm" border-style="solid" border-color="rgb(255,255,255)">
		<fo:block>
			<fo:external-graphic height= "74mm" src="http://tusk.tufts.edu{@SRC}"/>
		</fo:block>
		</fo:table-cell>
		<fo:table-cell>
		</fo:table-cell>

		<fo:table-cell number-columns-spanned="2" text-align="center"  border-width="1mm" border-style="solid" border-color="rgb(255,255,255)">
		<fo:block>
			<xsl:if test="not((position() + 1) &gt; last())">
			<fo:external-graphic height= "74mm"  src="http://tusk.tufts.edu{following-sibling::SLIDE[1]/attribute::SRC}"/>
			</xsl:if>
		</fo:block>
		</fo:table-cell>
		</fo:table-row>

	</xsl:if>
</xsl:for-each>
				</fo:table-body>
			</fo:table>
			</fo:flow>
		 </fo:page-sequence>
		
	</fo:root>
</xsl:template>
</xsl:stylesheet>
