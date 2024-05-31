//
//  BridgingHeader.h
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

#ifndef BridgingHeader_h
#define BridgingHeader_h

#include <zip.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

void read_docx(const char *filename, void (*callback)(const char *));

#endif /* BridgingHeader_h */
