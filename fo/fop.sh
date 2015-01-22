java -cp \
/usr/local/xml_jar/fop.jar:\
/usr/local/xml_jar/w3c.jar:\
/usr/local/xml_jar/xml.jar:\
/usr/local/xml_jar/xerces.jar:\
/usr/local/xml_jar/xalan.jar:\
/usr/local/xml_jar/bsf.jar \
org.apache.fop.apps.CommandLine $1 $2
