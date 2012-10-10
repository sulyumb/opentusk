<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.0">

    <xsl:include href="../Common/flow.xsl"/>
    <xsl:output method="html"/>
    <xsl:template match="course">
	<h3 class="title">Course Description</h3>
        <xsl:value-of select="course-description" disable-output-escaping ="yes"/>
    </xsl:template>
</xsl:stylesheet>
