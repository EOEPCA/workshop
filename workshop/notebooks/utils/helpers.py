import lxml.etree as etree
import sys
import os
import string
import hashlib
import time

namespaces = dict()

namespaces['owc'] = 'http://www.opengis.net/owc/1.0'

class Atom(object):
    tree = None
    root = None
    entry = None
    
    def __init__(self, root):

        self.root = root
        self.links = self.root.xpath('/a:feed/a:entry/a:link', 
                                     namespaces={'a':'http://www.w3.org/2005/Atom'})
        
        entries = self.root.xpath('/a:feed/a:entry', 
                                  namespaces={'a':'http://www.w3.org/2005/Atom'})
        if len(entries) > 0:
            self.entry = entries[0]

    @staticmethod
    def from_template(template=os.path.join(os.path.abspath(os.path.dirname(__file__)), 'empty_template.xml')):
        """Create an atom with 1 entry from template"""
        tree = etree.parse(template)
        return Atom(tree)

    def set_identifier(self, identifier):
        """Set first atom entry identifier
        """
    
        el_identifier = self.root.xpath('/a:feed/a:entry/d:identifier', 
                                        namespaces={'a':'http://www.w3.org/2005/Atom',
                                                    'd':'http://purl.org/dc/elements/1.1/'})
    
        el_identifier[0].text = identifier
        
    
    
    @staticmethod
    def create_offering(code, operations = None, content=None):

        offering = etree.Element('{{{}}}offering'.format(namespaces['owc']))

        offering.attrib['code'] = code

        if content is not None:
            
            c = etree.SubElement(offering, '{{{}}}content'.format(namespaces['owc']))
            c.set("type", "application/cwl")
            c.text = content
       
        
        if operations is not None:

            for operation in operations:

                offering.append(operation)

        return  offering


   
    
    def set_title_text(self, text):
        """Set first atom entry title
        """
    
        el_title = self.root.xpath('/a:feed/a:entry/a:title', 
                                   namespaces={'a':'http://www.w3.org/2005/Atom'})
    
        el_title[0].text = text
        
    def get_summary(self, create=False):
        # get or create summary
        summaries = self.root.xpath('/a:feed/a:entry/a:summary', 
                                    namespaces={'a':'http://www.w3.org/2005/Atom'})
        
        if (len(summaries) == 0):
            if (create):
                summaries = [etree.SubElement(self.entry, "{http://www.w3.org/2005/Atom}summary")]
                return summaries[0]
            return None
            
        return summaries[0]
        
    def set_summary_text(self, text):
        # get or create summary
        summary = self.get_summary(True)
            
        summary.text = text
        
    
    def add_offering(self, offering):
    
        self.root.xpath('/a:feed/a:entry', namespaces={'a':'http://www.w3.org/2005/Atom'})[0].append(offering)
         
   
    def get_dcdate(self, create):
        
        # get or create dcdate
        el_dates = self.root.xpath('/a:feed/a:entry/d:date', 
                          namespaces={'a':'http://www.w3.org/2005/Atom',
                               'd':'http://purl.org/dc/elements/1.1/'})
        
        if (len(el_dates) == 0):
            if (create):
                el_dates = [etree.SubElement(self.entry, "{http://purl.org/dc/elements/1.1/}date")]
                return el_dates[0]
            return None
            
        return el_dates[0]
    
    def set_dcdate(self, date):
    
        # get or create dcdate
        dcdate = self.get_dcdate(True)
            
        dcdate.text = date
        

    def to_string(self, pretty_print = True):
        # here etree, root
        return etree.tostring(self.root, pretty_print=pretty_print)
    
    