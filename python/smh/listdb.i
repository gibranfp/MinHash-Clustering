/* listdb.i */
%module listdb
%include typemaps.i
%include "exception.i"
%{
#include "array_lists.h"
#include "listdb.h"
#include <assert.h>

     static int myErr = 0;

     %}
 
extern void listdb_init(ListDB *listdb);
extern ListDB listdb_create(int, int);
extern ListDB listdb_random(uint, uint, uint);
extern void listdb_clear(ListDB *listdb);
extern void listdb_destroy(ListDB *);
extern void listdb_print(ListDB *);
extern void listdb_print_multi(ListDB *, List *);
extern void listdb_print_range(ListDB *, uint, uint);
extern void listdb_delete_smallest(ListDB *, uint);
extern void listdb_delete_largest(ListDB *, uint);

extern ListDB listdb_load_from_file(char *filename);
extern void listdb_save_to_file(char *filename, ListDB *listdb);

typedef struct ListDB{
     uint size;
     uint dim;
     List *lists;
}ListDB;

typedef unsigned int uint;

%exception ListDB::__getitem__ {
     assert(!myErr);
     $action
          if (myErr) {
               myErr = 0; // clear flag for next time
               SWIG_exception(SWIG_IndexError, "Index out of bounds");
          }
}

%extend ListDB {
     List __getitem__(size_t i) {
          if (i >= $self->size) {
               myErr = 1;
               List list = (const List) {0};
               return list;
          }
          return $self->lists[i];
     }

     uint *rows(void) {
          uint i;
          uint *rows = NULL;
          uint counter = 0;
          for (i = 0; i < $self->size; i++) {
               rows = (uint *) realloc(rows, (counter + $self->lists[i].size) * sizeof(uint));
               memset(&rows[counter], i, $self->lists[i].size);
               counter += $self->lists[i].size;
          }

          return rows;
     }

     uint *cols(void) {
          uint i, j;
          uint *cols = NULL;
          uint counter = 0;
          for (i = 0; i < $self->size; i++) {
               cols = (uint *) realloc(cols, counter + $self->lists[i].size);
               for (j = 0; j < $self->lists[i].size; j++) 
                    cols[counter + j] = $self->lists[i].data[j].item;
               counter += $self->lists[i].size;
          }

          return cols;
     }

     uint *array(void) {
          uint i, j;
          uint *array = NULL;
          uint counter = 0;
          for (i = 0; i < $self->size; i++) {
               array = (uint *) realloc(array, counter + $self->lists[i].size);
               for (j = 0; j < $self->lists[i].size; j++) 
                    array[counter + j] = $self->lists[i].data[j].freq;
               counter += $self->lists[i].size;
          }

          return array;
     }
}
