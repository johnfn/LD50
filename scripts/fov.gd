extends Node2D

"""
@author: Alex Hall
Computes a 2D Visibility Polygon using Shadowcasting. 
Algorithm from: https://www.redblobgames.com/articles/visibility/
Additional Implementation Ideas from: https://github.com/trylock/visibility
Notes: 
* Not optimized for performance. It is reasonable for low geometry counts, but may not scale well.
* Favors readability over concision
* Cannot handle intersecting polygons. 
  * This could be added by computing segment intersections and dividing into smaller segments at intersection points
* FOV polygon must be closed
  * This can be ensured by adding a bounding box around the scene. 
"""

func get_fov_from_polygons(polygons, origin):
  var segments = polygon_collection_to_segments(polygons, origin)
  var fov = get_fov_from_segments(segments, origin)
  return fov
        
func polygon_collection_to_segments(polygons, origin):
  var fov_segments = []
  for p in polygons:
    for segment in polygon_to_segments(p, origin):
      fov_segments.append(segment)
  return fov_segments
  
func polygon_to_segments(poly, origin):
  #need to pass in origin to filter segments colinear with origin. 
  var segments = []
  for i in range(len(poly)):
    var new_seg = LineSegment.new(poly[i], poly[i-1])
    if valid_segment(new_seg, origin):
      segments.append(new_seg)
  return segments
  
func valid_segment(segment, origin):
  var oab = Comparisons.new(origin).compute_orientation(segment.a, segment.b, origin)
  if oab == ORIENTATION.colinear:
    pass
  return oab != ORIENTATION.colinear
  
func get_fov_from_segments(segments, origin):
  var data = store_segments_as_events(segments, origin, [], OrderedSet.new(origin))
  data['events'] = sort_events_by_angle(origin, data['events'])
  var vertices = find_visibility_polygon(data['events'], data['state'], origin)
  var polygon = remove_colinear_points(vertices)
  return polygon
  
func store_segments_as_events(segment_collection, origin, events=[], state=OrderedSet.new(Vector2(0,0))):
  for segment in segment_collection:
    #sort segments and add them as events
    # skip line segments colinear with point
    var reverse_segment = LineSegment.new(segment.b, segment.a)
    var a = segment.a
    var b = segment.b
    var pab = Comparisons.compute_orientation(origin, a, b)
    if pab == ORIENTATION.colinear:
      print('skipping')
      continue
    elif pab == ORIENTATION.right_turn:
      events.append(VisibilityEvent.new(EVENT_TYPE.start_vertex, segment))
      events.append(VisibilityEvent.new(EVENT_TYPE.end_vertex, reverse_segment))
    else:
      events.append(VisibilityEvent.new(EVENT_TYPE.start_vertex, reverse_segment))
      events.append(VisibilityEvent.new(EVENT_TYPE.end_vertex, segment))
    
    # initialize state by adding line segments that are intersected
    # by vertical ray
    if a.x < b.x:
      var tmp = a
      a = b
      b = tmp

    var abp = Comparisons.compute_orientation(a,b, origin)
    var b_on_south_ray = Comparisons.approx_equal_float(b.x, origin.x)
    
    var south_ray_intersects_segment = a.x > origin.x and origin.x > b.x
    
    var is_clockwise_edge = abp == ORIENTATION.right_turn
    if is_clockwise_edge and (b_on_south_ray or south_ray_intersects_segment):
      state.insert(segment)
    
  var data = {
    'events': events,
    'state': state,
  }	
  return data 
  
func sort_events_by_angle(origin, events):
  events.sort_custom(Comparisons.new(origin), "compare_event")
  return events	
    
func find_visibility_polygon(events, state, origin):
  # ray shoots down 
  # recall: positive Y points DOWN
  var vertices = []
  for event in events:
    if event.type == EVENT_TYPE.end_vertex:
      var s = event.segment
      var rs = reverse_segment(s)
      state.erase(event.segment)
      state.erase(reverse_segment(event.segment))
    if state.empty():
      vertices.append(event.point())
    elif Comparisons.new(origin).compare_segment(event.segment, state.first()):
      # nearest line segment has changed
#			# compute the intersection point with this segment
      var ray = Ray.new(origin, event.point() - origin)
      var nearest_segment = state.first()
      var intersection_data = ray_intersects(ray, nearest_segment)
      var intersection = intersection_data['at']
      var intersects = intersection_data['exists']
      
      #ray intersects line segment L iff L is in state

      if event.type == EVENT_TYPE.start_vertex:
        vertices.append(intersection)
        vertices.append(event.point())
      else:
        vertices.append(event.point())
        vertices.append(intersection)
    
    if event.type == EVENT_TYPE.start_vertex:
      state.insert(event.segment)
  return vertices
  
func remove_colinear_points(vertices):
  var top = 0
  for idx in range(len(vertices)):
    var prev = top - 1
    var next = (idx + 1) % len(vertices)
    var pvtx = vertices[prev]
    var cvtx = vertices[idx]
    var nvtx = vertices[next]
    var orientation = Comparisons.compute_orientation(pvtx, cvtx, nvtx)
    if orientation != ORIENTATION.colinear:
      vertices[top] = vertices[idx]
      top += 1
  
  var new_verts = []
  for i in range(top):
    new_verts.append(vertices[i])
  
  return new_verts


        
        
# *********************************************************************************************************
# Support Functions
# *********************************************************************************************************
  
func normal(vec2):
  #this is to parallel code from https://github.com/trylock/visibility/blob/master/tests/vector2_test.cpp
  #refactor once working.
  return (-vec2).tangent()

func reverse_segment(line_segment):
  return LineSegment.new(line_segment.b, line_segment.a)

static func ray_intersects(ray, segment):
  var ao = ray.origin - segment.a
  var ab = segment.b - segment.a
  var det = Comparisons.cross(ab, ray.direction)
  var false_result = {
    'exists':false,
    'at':null
  }
  var output = {
    'exists':true,
    'at':null,
  }
  if Comparisons.approx_equal_float(det,0.0):
    var abo = Comparisons.compute_orientation(segment.a, segment.b, ray.origin)
    if abo != ORIENTATION.colinear:
      return false_result
    var dist_a = ao.dot(ray.direction)
    var dist_b = (ray.origin-segment.b).dot(ray.direction)
    if dist_a > 0.0 and dist_b > 0.0:
      return false_result
    elif ((dist_a > 0.0) != (dist_b >0.0)):
      output['at'] = ray.origin
    elif dist_a > dist_b:
      output['at'] = segment.a
    else:
      output['at'] = segment.b
  else:	
    var u = Comparisons.cross(ao, ray.direction) / det
    if u < 0.0 or 1.0 < u:
      return false_result
    
    var t = -1 * Comparisons.cross(ab, ao) / det
    output['at'] = ray.origin + t * ray.direction
    output['exists'] = Comparisons.approx_equal_float(t,0.0) or t > 0.0
  return output
  
  
# *********************************************************************************************************
# Support Classes
# *********************************************************************************************************
const FLOAT_EPSILON = 0.00001

enum ORIENTATION {
        right_turn = 1,
        left_turn = -1,
        colinear = 0
    };
  
enum EVENT_TYPE{start_vertex=0, 
        end_vertex=1}	
  
class VisibilityEvent:

  var type
  var segment
  
  func _init(type=null, segment=null):
    self.type = type
    self.segment = segment
    
  func point():
    return self.segment.a	
    
class LineSegment:
  export var a = Vector2()
  export var b = Vector2()
  func _init(a, b):
    self.a = a
    self.b = b
    
class Ray:
  export var origin = Vector2()
  export var direction = Vector2()
  func _init(origin, direction):
    self.origin = origin
    self.direction = direction		


class Comparisons:
  var origin
  func _init(origin = Vector2(16,16)):
    self.origin = origin
    
  static func approx_equal_float(a, b, epsilon = FLOAT_EPSILON):
      return abs(a - b) <= epsilon

  static func cross(a, b):
    return a.x * b.y - a.y * b.x
  
  static func approx_equal_vector(a,b,epsilon=FLOAT_EPSILON):
    var same_x = approx_equal_float(a.x, b.x, epsilon)
    var same_y = approx_equal_float(a.y, b.y, epsilon)
    return same_x and same_y 
    
  func compare_segment(a,b):
    return line_segment_is_closer(a,b, self.origin) 
    
  static func compute_orientation(a, b, c):
    var det = cross(b - a, c - a)
    var pos = 1 if 0.0 < det else 0.0
    var neg = 1 if det < 0.0 else 0.0
    return pos - neg

    
  static func line_segment_is_closer(x,y, origin):
    var a = x.a
    var b = x.b
    var c = y.a
    var d = y.b
    #assert not compute_orientation(origin, a, b) == ORIENTATION.colinear
    #assert not compute_orientation(origin, c, d) == ORIENTATION.colinear
    
    #sort the endpoints so that if there are common endpoints, they will be a and c
    if approx_equal_vector(b,c) or approx_equal_vector(b,d):
      var tmp = a
      a = b
      b = tmp
    if approx_equal_vector(a,d):
      var tmp = c
      c = d
      d = tmp
    
    #cases with common endpoints
    if approx_equal_vector(a, c):
      var oad = compute_orientation(origin, a, d)
      var oab = compute_orientation(origin, a, b)
      var a_is_between_d_and_b = oad != oab
      if approx_equal_vector(b, d) or a_is_between_d_and_b:
        return false
        
      var ab_is_between_origin_and_d = compute_orientation(a, b, d) != compute_orientation(a,b,origin)
      return ab_is_between_origin_and_d
    
    #cases without common endpoints
    var cda = compute_orientation(c,d,a)
    var cdb = compute_orientation(c,d,b)
    var segments_are_colinear_and_parallel_to_origin = cdb == ORIENTATION.colinear and cda == ORIENTATION.colinear
    if segments_are_colinear_and_parallel_to_origin:
      var a_is_closer_to_origin = origin.distance_to_squared(a) < origin.distance_to_squared(c)
      return 	a_is_closer_to_origin	
      
    var cd_and_ab_will_never_intersect = cda == cdb
    var line_from_cd_touches_enpdoint_a = cda == ORIENTATION.colinear
    var line_from_cd_touches_endpoint_b = cdb == ORIENTATION.colinear
    var cd_only_touches_an_endpoint = line_from_cd_touches_endpoint_b or line_from_cd_touches_enpdoint_a
    var no_intersection = cd_and_ab_will_never_intersect or cd_only_touches_an_endpoint
    if no_intersection:
      var cdo = compute_orientation(c, d, origin)
      return cdo == cda or cdo == cdb
    else: #extending cd would intersect ab
      var abo = compute_orientation(a, b, origin)
      var abc = compute_orientation(a,b,c)
      var ab_intersects_cd = abo != abc
      return ab_intersects_cd
      
        
  func compare_event(a,b):
    if approx_equal_vector(a.point(), b.point()):
      return (a.type == EVENT_TYPE.end_vertex and b.type == EVENT_TYPE.start_vertex)
    return is_clockwise(a.point(), b.point(), origin)
    
  static func is_counter_clockwise(a, b, origin):
    # compare angles clockwise starting at the positive y axis
    var a_is_left = a.x < origin.x
    var b_is_left = b.x < origin.x
    if a_is_left != b_is_left:
      return b_is_left
      
    if approx_equal_float(a.x, origin.x) and approx_equal_float(b.x, origin.x):
      if not a.y < origin.y or not b.y < origin.y:
        return b.y < a.y
      return a.y < b.y
    
    var oa = a - origin
    var ob = b - origin
    var det = cross(oa, ob)
    if approx_equal_float(det, 0.0):
      return oa.length_squared() < ob.length_squared()
    return det < 0
    
  static func is_clockwise(a,b,origin):
    var a_is_right = a.x > origin.x
    var b_is_right = b.x > origin.x
    if a_is_right != b_is_right:
      return b_is_right
    if approx_equal_float(a.x, b.x) and approx_equal_float(b.x, origin.x):
      if not a.y > origin.y or not b.y > origin.y:
        return b.y < a.y
      return a.y < b.y
    var oa = a - origin
    var ob = b - origin
    var det = cross(oa, ob)
    if approx_equal_float(det, 0.0):
      return oa.length_squared() > ob.length_squared()
    return det > 0.0 
    
      
class OrderedSet:
  var data = []
  var origin = null
  
  func _init(origin):
    self.origin = origin
    
  func empty():
    return data.empty()
    
  func erase(object):
    var match_idx = find(object)
    if match_idx != null:
        self.data.remove(match_idx)
          
  func has(object):
    return find(object) != false

  func object_matches(x,y):
    return x.a == y.a and x.b == y.b 
  
  func length():
    return len(data)
    
  func find(object):
    var best_idx = bsearch(object, self.data)
    if len(self.data) >  best_idx:
      var obj = self.data[best_idx]
      if 	object_matches(object, obj):
        return best_idx 
    return null
  
  func first():
    return data[0] if not self.empty() else null
    
  func middle(list):
    var mid_idx = floor(len(list) / 2)
    return mid_idx
    
  func bsearch(segment, dataset):
    return dataset.bsearch_custom(segment, Comparisons.new(origin), "compare_segment")
      

  func insert(segment):
    var best_idx = bsearch(segment, self.data)
    if  len(self.data) <= best_idx or not object_matches(segment, self.data[best_idx]):
      self.data.insert(best_idx, segment)

