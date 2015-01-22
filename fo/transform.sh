java -cp /usr/local/xml_jar/xalan.jar:\
/usr/local/xml_jar/xerces.jar:\
/usr/local/xml_jar/bsf.jar \
org.apache.xalan.xslt.Process -IN $1 -XSL $2 -OUT $3
