//
//  DocxReader.c
//  script_parser
//
//  Created by Jean Dumont on 28/05/2024.
//

#include <stdio.h>
#include <zip.h>
#include <libxml/parser.h>
#include <libxml/tree.h>

#include <stdio.h>
#include <stdlib.h>
#include <zip.h>
#include <libxml/parser.h>
#include <libxml/tree.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/*
// Function to extract text content from a cell node
char* extract_text_from_cell(xmlNode *cell_node) {
    xmlNode *text_node = cell_node->children;
    xmlBufferPtr buffer = xmlBufferCreate();
    
    while (text_node) {
        if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "r") == 0) {
            xmlNode *t_node = text_node->children;
            while (t_node) {
                if (t_node->type == XML_ELEMENT_NODE && strcmp((const char *)t_node->name, "t") == 0) {
                    xmlChar *content = xmlNodeGetContent(t_node);
                    if (content) {
                        xmlBufferCat(buffer, content);
                        xmlFree(content);
                    }
                }
                t_node = t_node->next;
            }
        }
        text_node = text_node->next;
    }

    char *result = (char *)malloc(buffer->use + 1);
    strcpy(result, (char *)buffer->content);
    xmlBufferFree(buffer);
    return result;
}

// Function to process a tbl node and return a 2-dimensional array with cell text content
char*** extract_table_text(xmlNode *tbl_node, int *rows, int *cols) {
    int max_cols = 0;
    int row_count = 0;

    // First pass to count rows and columns
    xmlNode *row_node = tbl_node->children;
    while (row_node) {
        if (row_node->type == XML_ELEMENT_NODE && strcmp((const char *)row_node->name, "tr") == 0) {
            int col_count = 0;
            xmlNode *cell_node = row_node->children;
            while (cell_node) {
                if (cell_node->type == XML_ELEMENT_NODE && strcmp((const char *)cell_node->name, "tc") == 0) {
                    col_count++;
                }
                cell_node = cell_node->next;
            }
            if (col_count > max_cols) {
                max_cols = col_count;
            }
            row_count++;
        }
        row_node = row_node->next;
    }

    // Allocate memory for the 2-dimensional array
    char ***table = (char ***)malloc(row_count * sizeof(char **));
    for (int i = 0; i < row_count; i++) {
        table[i] = (char **)malloc(max_cols * sizeof(char *));
        for (int j = 0; j < max_cols; j++) {
            table[i][j] = NULL;
        }
    }

    // Second pass to fill the array with cell text content
    int row_index = 0;
    row_node = tbl_node->children;
    while (row_node) {
        if (row_node->type == XML_ELEMENT_NODE && strcmp((const char *)row_node->name, "tr") == 0) {
            int col_index = 0;
            xmlNode *cell_node = row_node->children;
            while (cell_node) {
                if (cell_node->type == XML_ELEMENT_NODE && strcmp((const char *)cell_node->name, "tc") == 0) {
                    table[row_index][col_index] = extract_text_from_cell(cell_node);
                    col_index++;
                }
                cell_node = cell_node->next;
            }
            row_index++;
        }
        row_node = row_node->next;
    }

    *rows = row_count;
    *cols = max_cols;
    return table;
}*/

typedef struct {
    char ***table;
    int rows;
    int cols;
} Table;


typedef void (*tables_callback)(Table *tables, int table_count);

// Function to count the number of rows and columns
void count_rows_and_cols(xmlNode *tbl_node, int *rows, int *cols) {
    *rows = 0;
    *cols = 0;
    for (xmlNode *row_node = tbl_node->children; row_node; row_node = row_node->next) {
//        printf("     >  Node name: %s\n", row_node->name);

        if (row_node->type == XML_ELEMENT_NODE && strcmp((const char*)row_node->name, "tr") == 0) {
            (*rows)++;
//            printf("row\n");
            int current_cols = 0;
            for (xmlNode *cell_node = row_node->children; cell_node; cell_node = cell_node->next) {
              //  printf("    >  CellNode name: %s\n", cell_node->name);
                if (cell_node->type == XML_ELEMENT_NODE && strcmp((const char*)cell_node->name, "tc") == 0) {
  //                  printf("cell\n");
                  //  printf("    >  tc : %s\n", cell_node->content);
                    
                    xmlNode *cell_text_node = cell_node->children;
                    while (cell_text_node) {
        //                printf("    >  tc > children = %s\n", cell_text_node->content);
                        if (cell_text_node->type == XML_ELEMENT_NODE && strcmp((const char *)cell_text_node->name, "p") == 0) {
      //                      printf("    >      tc > p = %s\n",cell_text_node->content);
                            // Handle paragraph in cell
                            xmlNode *text_node = cell_text_node->children;
                            while (text_node) {
    //                            printf("        >  tc > p > children : %s\n", text_node->name);
                                if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "t") == 0) {
  //                                  printf("    >      tc > p > t");
                                   // callback((const char *)xmlNodeGetContent(text_node));
                                }
                                if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "r") == 0) {
//                                    printf("    >      tc > p > r %s\n",text_node->content);

                                    xmlNode *rchild_node = text_node->children;
                                    while (rchild_node) {
                                        //printf("    >      tc > p > r > children %s\n",rchild_node->name);
                                        
                                        if (rchild_node->type == XML_ELEMENT_NODE && strcmp((const char *)rchild_node->name, "t") == 0) {
                                        //    printf("    >     tc > p > r > t %s\n",rchild_node->content);
                                           // callback((const char *)xmlNodeGetContent(text_node));
                                        }
                                        
                                        rchild_node = rchild_node->next;

                                        
                                    }
                                    // callback((const char *)xmlNodeGetContent(text_node));
                                }
                                text_node = text_node->next;
                            }
                        }
                        cell_text_node = cell_text_node->next;
                    }
                    
                    
                    current_cols++;
                }
            }
            if (current_cols > *cols) {
                *cols = current_cols;
            }
        }
    }
}

// Function to extract cell contents into a two-dimensional array
char*** extract_table_contents(xmlNode *tbl_node, int rows, int cols) {
    char ***table = (char***)malloc(rows * sizeof(char**));
    if (table == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(1);
    }
    
    int row_index = 0;
    for (xmlNode *row_node = tbl_node->children; row_node; row_node = row_node->next) {
   //     printf("Node name: %s\n", row_node->name);
       
        if (row_node->type == XML_ELEMENT_NODE && strcmp((const char*)row_node->name, "tr") == 0) {
            table[row_index] = (char**)malloc(cols * sizeof(char*));
            if (table[row_index] == NULL) {
                fprintf(stderr, "Memory allocation failed\n");
                exit(1);
            }
            
            int col_index = 0;
            for (xmlNode *cell_node = row_node->children; cell_node; cell_node = cell_node->next) {
               //printf("child name: %s\n", cell_node->name);

                if (cell_node->type == XML_ELEMENT_NODE && strcmp((const char*)cell_node->name, "tc") == 0) {
                    xmlChar *content = xmlNodeGetContent(cell_node);
                    table[row_index][col_index] = strdup((const char*)content);
                    xmlFree(content);
                    col_index++;
                }
            }
            
            // Fill remaining columns with NULL
            while (col_index < cols) {
                table[row_index][col_index] = NULL;
                col_index++;
            }
            
            row_index++;
        }
    }
    
    return table;
}

// Function to free the allocated table contents
void free_table_contents(char ***table, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (table[i][j] != NULL) {
                free(table[i][j]);
            }
        }
        free(table[i]);
    }
    free(table);
}

// Function to find the body node within the document node
xmlNode* find_table_node(xmlNode *root) {
    for (xmlNode *cur_node = root; cur_node; cur_node = cur_node->next) {
        if (cur_node->type == XML_ELEMENT_NODE && strcmp((const char*)cur_node->name, "tbl") == 0) {
            return cur_node;
        }
        xmlNode *body = find_table_node(cur_node->children);
        if (body) {
            return body;
        }
    }
    return NULL;
}
char*  read_docx_node(xmlNode *node) {
    size_t total_length = 10;
    char* res = (char*)malloc((total_length + 1) * sizeof(char));
    // Extract and pass the content to the callback
    while (node) {
//        printf("c read_docx node\n");
        printf("Node name: %s\n", node->name);
        xmlNode *text_node = node->children;
        while (text_node) {
            printf("Children: %s\n", text_node->name);
            text_node = text_node->next;
        }
        if (node->type == XML_ELEMENT_NODE) {
            
            if (strcmp((const char *)node->name, "p") == 0) {
                printf("Node type: paragraph");
                
                // Handle paragraph
                xmlNode *text_node = node->children;
                while (text_node) {
                    if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "t") == 0) {
                        printf("Node type: t in paragraph");

                      //  callback((const char *)xmlNodeGetContent(text_node));
                    }
                    text_node = text_node->next;
                }
            } else if (strcmp((const char *)node->name, "tbl") == 0) {
                printf("Node type: table");
                // Handle table
                xmlNode *row_node = node->children;
                while (row_node) {
                    if (row_node->type == XML_ELEMENT_NODE && strcmp((const char *)row_node->name, "tr") == 0) {
                        printf("Node type: tr");

                        // Handle table row
                        xmlNode *cell_node = row_node->children;
                        while (cell_node) {
                            if (cell_node->type == XML_ELEMENT_NODE && strcmp((const char *)cell_node->name, "tc") == 0) {
                                // Handle table cell
                                printf("Node type: cell");

                                xmlNode *cell_text_node = cell_node->children;
                                while (cell_text_node) {
                                    if (cell_text_node->type == XML_ELEMENT_NODE && strcmp((const char *)cell_text_node->name, "p") == 0) {
                                        printf("Node type: p in cell");
                                        // Handle paragraph in cell
                                        xmlNode *text_node = cell_text_node->children;
                                        while (text_node) {
                                            if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "t") == 0) {
                                                printf("Node type: t in cell");

                                               // callback((const char *)xmlNodeGetContent(text_node));
                                            }
                                            text_node = text_node->next;
                                        }
                                    }
                                    cell_text_node = cell_text_node->next;
                                }
                            }
                            cell_node = cell_node->next;
                        }
                    }
                    row_node = row_node->next;
                }
            }
        }
        node = node->next;
    }
    return res;
}
xmlNode* find_body_node(xmlNode *root) {
    for (xmlNode *cur_node = root; cur_node; cur_node = cur_node->next) {
        if (cur_node->type == XML_ELEMENT_NODE && strcmp((const char*)cur_node->name, "body") == 0) {
            return cur_node;
        }
        xmlNode *body = find_body_node(cur_node->children);
        if (body) {
            return body;
        }
    }
    return NULL;
}
char *** get_table(xmlNode *tbl_node){
    // Count rows and columns
       int rows, cols;
       count_rows_and_cols(tbl_node, &rows, &cols);

       // Extract table contents
       char ***table = extract_table_contents(tbl_node, rows, cols);

       // Print the table contents
       for (int i = 0; i < rows; i++) {
           for (int j = 0; j < cols; j++) {
               if (table[i][j] != NULL) {
                   printf("%s\t", table[i][j]);
               } else {
                   printf("NULL\t");
               }
           }
           printf("\n");
       }
    return table;
       // Free the allocated memory
//       free_table_contents(table, rows, cols);
}
void print_table_contents(char ***table, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            if (table[i][j] != NULL) {
                printf("%s\t", table[i][j]);
            } else {
                printf("NULL\t");
            }
        }
        printf("\n");
    }
}
void read_docx(const char *filename, void (*callback)(const char *)) {
    printf("c read_docx\n");
    
    int err;
    zip_t *zip = zip_open(filename, 0, &err);
    if (!zip) {
        printf("Error opening ZIP archive: %d\n", err);
        return;
    }
    
    zip_file_t *file = zip_fopen(zip, "word/document.xml", 0);
    if (!file) {
        printf("Error opening document.xml in DOCX archive\n");
        zip_close(zip);
        return;
    }
    
    zip_stat_t stat;
    zip_stat(zip, "word/document.xml", 0, &stat);
    
    char *contents = malloc(stat.size + 1);
    if (zip_fread(file, contents, stat.size) == -1) {
        printf("Error reading document.xml\n");
        free(contents);
        zip_fclose(file);
        zip_close(zip);
        return;
    }
    contents[stat.size] = '\0';
    
    zip_fclose(file);
    zip_close(zip);
    printf("c read_docx 1\n");
    // Parse the XML content
    xmlDoc *doc = xmlReadMemory(contents, stat.size, "document.xml", NULL, 0);
    if (doc == NULL) {
        printf("Failed to parse document.xml\n");
        free(contents);
        return;
    }
    
    xmlNode *root_element = xmlDocGetRootElement(doc);
    if (root_element == NULL) {
        printf("Empty document\n");
        xmlFreeDoc(doc);
        free(contents);
        return;
    }
    printf("c read_docx 2\n");
    printf(" >  Root name: %s\n", root_element->name);
    xmlNode * body_node=find_body_node(root_element);
    
    if (body_node && strcmp((const char *)body_node->name, "body") == 0) {
        printf(" >  Body name: %s\n", root_element->name);
        xmlNode* text_node= body_node->children;

        
        while (text_node) {
            printf(" >  Node type: children\n");
           // if (text_node->type == XML_ELEMENT_NODE && strcmp((const char *)text_node->name, "t") == 0) {
            xmlNode * tbl_node=find_table_node(body_node);
            if (tbl_node!=NULL){
                
                    printf(" >  Node type: table\n");
                int rows, cols;
                count_rows_and_cols(tbl_node, &rows, &cols);
                printf(" >  Table size: %d x %d\n", rows,cols);
                char*** table=  get_table(tbl_node);
             //   print_table_contents(table, rows, cols);
                free_table_contents(table, rows, cols);

//                char * res=read_docx_node(tbl_node);
            }
            text_node = text_node->next;
        }
            
   
    } else {
        printf("Error: root element is not <body>\n");
    }

    
    
    printf("c read_docx 4");
    // Clean up
    xmlFreeDoc(doc);
    free(contents);
}


