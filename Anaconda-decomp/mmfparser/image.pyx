# Copyright (c) Mathias Kaerlev 2012.

# This file is part of Anaconda.

# Anaconda is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Anaconda is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Anaconda.  If not, see <http://www.gnu.org/licenses/>.

cdef extern from "stb_image.c":
    unsigned char * stbi_load(char *filename, int *x, int *y, int *comp,
                              int req_comp)
    unsigned char * stbi_load_from_memory(unsigned char * buffer, int len,
                                          int *x, int *y, int *comp,
                                          int req_comp)
    void stbi_image_free (void *retval_from_stbi_load)
    char * stbi_failure_reason()

class ImageException(Exception):
    pass

cdef class Image:
    def __init__(self, data = None, filename = None):
        cdef int x, y, n
        cdef unsigned char * c_data
        if filename is not None:
            c_data = stbi_load(filename, &x, &y, &n, 4)
        elif data is not None:
            c_data = stbi_load_from_memory(data, len(data), &x, &y, &n, 4)
        else:
            raise ImageException('no data or file specified')
        if c_data == NULL:
            error = 'error loading image: %s' % stbi_failure_reason()
            if filename is not None:
                error += ' (file %s)' % filename
            raise ImageException(error)
        self.width = x
        self.height = y
        self.channels = n
        self.c_data = c_data

    def get_data(self):
        if self.data is not None:
            return self.data
        self.data = (<char*>self.c_data)[:self.width * self.height * 4]
        self.close()
        return self.data

    cdef void close(self):
        if self.c_data != NULL:
            stbi_image_free(self.c_data)
            self.c_data = NULL

    def __del__(self):
        self.close()