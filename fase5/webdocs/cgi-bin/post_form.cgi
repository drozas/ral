#! /usr/bin/python
#



# Import some standard modules
import cgi
from types import *

# Some useful functions
def printNumberOfFields(form):
	print '<p>Number of sent fields: '+repr(len(form))+'</p>'

def printFields(form):
	keysList = form.keys()
	for index in range(0,len(keysList)):
		print '<p>'
		print '<b>Field:</b> '+keysList[index]+'<br>'
		field = form[keysList[index]]
		if type(field) == ListType: #More than one value
			print '<b>Value:</b> '
			for sub_field in field:
				print sub_field.value+' '
		else:
			print '<b>Valor:</b> '+form[keysList[index]].value
		print '</p>'

form = cgi.FieldStorage()

# Sending header
print "Content-Type: text/html\r"
print "\r"

print "<html><head><title>Script results</title></head>"
print "<body>"
printNumberOfFields(form)
printFields(form)
print "</body></html>"


