#cython: cdivision=True
#cython: boundscheck=False
#cython: nonecheck=False
#cython: wraparound=False
import numpy as np

cimport numpy as cnp
from skimage._shared.geometry cimport point_in_polygon, points_in_polygon


def grid_points_inside_poly(shape, verts):
    """Test whether points on a specified grid are inside a polygon.

    For each ``(r, c)`` coordinate on a grid, i.e. ``(0, 0)``, ``(0, 1)`` etc.,
    test whether that point lies inside a polygon.

    Parameters
    ----------
    shape : tuple (M, N)
        Shape of the grid.
    verts : (V, 2) array
        Specify the V vertices of the polygon, sorted either clockwise
        or anti-clockwise.  The first point may (but does not need to be)
        duplicated.

    Returns
    -------
    mask : (M, N) ndarray of bool
        True where the grid falls inside the polygon.

    """
    cdef cnp.ndarray[cnp.double_t, ndim=1, mode="c"] vx, vy
    verts = np.asarray(verts)

    vx = verts[:, 0].astype(np.double)
    vy = verts[:, 1].astype(np.double)
    cdef Py_ssize_t V = vx.shape[0]

    cdef Py_ssize_t M = shape[0]
    cdef Py_ssize_t N = shape[1]
    cdef Py_ssize_t m, n

    cdef cnp.ndarray[dtype=cnp.uint8_t, ndim=2, mode="c"] out = \
         np.zeros((M, N), dtype=np.uint8)

    for m in range(M):
        for n in range(N):
            out[m, n] = point_in_polygon(V, <double*>vx.data, <double*>vy.data,
                                         m, n)

    return out.view(bool)


def points_inside_poly(points, verts):
    """Test whether points lie inside a polygon.

    Parameters
    ----------
    points : (N, 2) array
     Input points, ``(x, y)``.
    verts : (M, 2) array
     Vertices of the polygon, sorted either clockwise or anti-clockwise.
     The first point may (but does not need to be) duplicated.

    Returns
    -------
    mask : (N,) array of bool
     True if corresponding point is inside the polygon.

    """
    cdef cnp.ndarray[cnp.double_t, ndim=1, mode="c"] x, y, vx, vy

    points = np.asarray(points)
    verts = np.asarray(verts)

    x = points[:, 0].astype(np.double)
    y = points[:, 1].astype(np.double)

    vx = verts[:, 0].astype(np.double)
    vy = verts[:, 1].astype(np.double)

    cdef cnp.ndarray[cnp.uint8_t, ndim=1] out = \
         np.zeros(x.shape[0], dtype=np.uint8)

    points_in_polygon(vx.shape[0], <double*>vx.data, <double*>vy.data,
                      x.shape[0], <double*>x.data, <double*>y.data,
                      <unsigned char*>out.data)

    return out.astype(bool)

