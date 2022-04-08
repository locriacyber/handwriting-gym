import numpy as np
from numba import jit

def distance(A, B, P):
    """ segment line AB, point P, where each one is an array([x, y]) """
    
    from numpy import arccos, array, dot, pi, cross
    from numpy.linalg import det, norm

    if all(A == P) or all(B == P):
        return 0
    if arccos(dot((P - A) / norm(P - A), (B - A) / norm(B - A))) > pi / 2:
        return norm(P - A)
    if arccos(dot((P - B) / norm(P - B), (A - B) / norm(A - B))) > pi / 2:
        return norm(P - B)
    return norm(cross(A-B, A-P))/norm(B-A)

def distance_from_line(p0, p1, xy):
    p0=np.array(p0)
    p1=np.array(p1)
    dist = p1-p0
    if np.all(dist == [0, 0]):
        direction = dist
    else:
        direction = dist / np.sqrt(np.sum(dist*dist))
    assert direction.shape == (2, )
        
    # distance from point to line
    magnitude = np.apply_along_axis(lambda p:distance(p0, p1, p), 2, xy)
    
    # ret = magnitude.reshape((*magnitude.shape,1)) * direction.reshape((1, 1, 2))
    # assert ret.shape[2] == 2
    return magnitude, direction

def linear_band(mag00, max_dist):
    return np.where(mag00 < max_dist, max_dist-mag00, 0)

def uv_len_squared(uv):
    return uv[...,0] ** 2 + uv[...,1] ** 2

def extend_1(a):
    return np.reshape(a, (*a.shape, 1))

def uv_norm(uv):
    # global len_squared
    len_squared = uv_len_squared(uv)
    len_ = np.sqrt(len_squared)
    return np.where(extend_1(len_squared > 1), uv / extend_1(len_), uv)

def line_to_vector_field(p, xy, band_width):
    p0, p1 = p
    mag, direction = distance_from_line(p0, p1, xy)
    mag = linear_band(mag, band_width)
    _dir = mag.reshape((*mag.shape,1)) / band_width * direction.reshape((1, 1, 2))
    return mag, _dir


### this is still slow
def polyline_to_vector_field(xy, points, band_width=10.0):
    mags = []
    dirs = []
    for ps in zip(points[:-1], points[1:]):
        mag0,dir0 = line_to_vector_field(ps, xy, band_width)
        mags.append(mag0)
        dirs.append(dir0)

    screen = np.max(mags, axis=0)
    screen_dir = np.sum(dirs, axis=0)
    return screen, screen_dir

def xy_mesh_grid(*xi):
    return np.stack(np.meshgrid(*xi), axis=-1)