<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">
    <xsl:template match="course">
        <h3 class="title">Content</h3>
        <xsl:apply-templates select="./content-list"/>
    </xsl:template>

    <xsl:template match="content-list">
        <xsl:variable name="contentLink">/hsdb4/content/</xsl:variable>
	<xsl:variable name="folderIcon">/icons/folder.gif</xsl:variable>
	<xsl:variable name="course-id" select="parent::course/@course-id"/>

	<xsl:if test="descendant::content-ref">
            <table width="100%">
	        <tr>
	            <th align="left">Type</th>
		    <th align="left">Document</th>
		    <th align="left">Authors</th>
	        </tr>
                <xsl:for-each select="./content-ref">
	            <tr>
		        <td>
		            <xsl:choose>
			        <xsl:when test="@content-type='Collection'">
			            <img src="{$folderIcon}"><xsl:text> </xsl:text></img>
			        </xsl:when>
			        <xsl:when test="@content-type='Slide'">
		                    <img width="36" height="36" src="/thumbnail/{@content-id}" border="0"><xsl:text> </xsl:text></img>
			        </xsl:when>
			        <xsl:otherwise>
			            <xsl:value-of select="@content-type"/>
			        </xsl:otherwise>
			    </xsl:choose>
		        </td>
		        <td>
			        <b><a href="{$contentLink}{$school_code}{$course-id}C/{@content-id}">
			            <xsl:value-of select="." disable-output-escaping ="yes"/>
			        </a></b>
		        </td>
		        <td><xsl:value-of select="@authors"/></td>
		    </tr>
	        </xsl:for-each>
	    </table>
	</xsl:if>
    </xsl:template>
</xsl:stylesheet>


