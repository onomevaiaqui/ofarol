import os,sys
_dll=os.add_dll_directory(os.path.join(sys.prefix,"Lib/site-packages/bpy")) if os.name=="nt" and os.path.isdir(os.path.join(sys.prefix,"Lib/site-packages/bpy")) else None
import bpy,math,json
from mathutils import Vector
from pathlib import Path
root=Path(__file__).resolve().parent.parent;assets=Path(os.environ.get('URBAN_ASSETS',str(root.parent/'survival-assets-source/urban/URBAN')));out=root/'.build/alley';out.mkdir(parents=True,exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24;scene.cycles.use_denoising=True
scene.render.resolution_x=480;scene.render.resolution_y=208;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard';scene.view_settings.look='Medium High Contrast';scene.view_settings.exposure=0;scene.view_settings.gamma=1
world=bpy.data.worlds.new('Night ambience');scene.world=world;world.use_nodes=True;world.node_tree.nodes['Background'].inputs[0].default_value=(0.13,0.17,0.24,1);world.node_tree.nodes['Background'].inputs[1].default_value=0.55
records=[]
def asset(rel,x,z,width=None,height=None,yaw=0,tag=''):
 before=set(bpy.data.objects);bpy.ops.import_scene.gltf(filepath=str(assets/rel));objs=[o for o in set(bpy.data.objects)-before if o.type=='MESH']
 # Apply imported GLTF node transformations before choosing common dimensions.
 coords=[o.matrix_world@Vector(p) for o in objs for p in o.bound_box];lo=Vector(tuple(min(p[i] for p in coords) for i in range(3)));hi=Vector(tuple(max(p[i] for p in coords) for i in range(3)))
 if width and hi.x-lo.x<0.05:
  from mathutils import Matrix
  for o in objs:o.matrix_world=Matrix.Rotation(math.pi/2,4,'Z')@o.matrix_world
  coords=[o.matrix_world@Vector(p) for o in objs for p in o.bound_box];lo=Vector(tuple(min(p[i] for p in coords) for i in range(3)));hi=Vector(tuple(max(p[i] for p in coords) for i in range(3)))
 scale=(height/(hi.z-lo.z)) if height else (width/(hi.x-lo.x)) if width else 1
 center=Vector(((lo.x+hi.x)/2,(lo.y+hi.y)/2,lo.z));a=math.radians(yaw);c,s=math.cos(a),math.sin(a)
 # Engine XYZ -> Blender (X,-Z,Y). Asset yaw in Blender degrees.
 from mathutils import Matrix
 ground=-(hi.z-lo.z)*scale if rel.startswith("Roads/") else 0
 transform=Matrix.Translation((x,z,ground))@Matrix.Rotation(a,4,'Z')@Matrix.Scale(scale,4)@Matrix.Translation(-center)
 for o in objs:o.matrix_world=transform@o.matrix_world;o['asset_tag']=tag
 records.append({'file':rel,'x':x,'z':z,'width':width,'height':height,'yaw':yaw,'tag':tag})
 return objs
asset('Roads/Road type 4/road_4_straight_no_sides.glb',0,-4,width=8)
asset('Roads/Road type 4/road_4_straight_no_sides.glb',0,4,width=8)
for x in [-3,0,3]:
 asset('Building Parts/brick_wall_metal_door.glb' if x==3 else 'Building Parts/brick_wall_window_1.glb',x,5.0,width=3)
 asset('Building Parts/brick_wall.glb',x,5.0,width=3,tag='upper')
 # Stack the second facade module above the first.
 for o in bpy.data.objects:
  if o.get('asset_tag')=='upper':o.location.z+=3;o['asset_tag']='stacked'
for z in [-3,0,3]:asset('Building Parts/brick_wall_window_2.glb',-4.15,z,width=3,yaw=90)
dumpster=asset('Litter/Dumpsters/dumpster_diagonal_closed.glb',-2.5,0.3,width=1.6,tag='occluder')
asset('Traffic lights/street_light.glb',3.15,1.8,height=4.5,yaw=180)
asset('Walls & Fences/metal_fence/metalfence_both_sides_topbar.glb',4.1,3,width=3,yaw=90)
def area(name,loc,power,color,size,target):
 d=bpy.data.lights.new(name,'AREA');d.energy=power;d.color=color;d.shape='DISK';d.size=size;o=bpy.data.objects.new(name,d);scene.collection.objects.link(o);o.location=loc;o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler()
area('Cool sky',(1,1,8),1000,(.60,.72,1),7,(0,0,0));area('Street lamp',(2.8,1.8,4.0),350,(1,.68,.32),2,(1,-1,0));area('Camera fill',(4,7,4),350,(.68,.76,1),5,(0,0,1))
d=bpy.data.cameras.new('Fixed game camera');camera=bpy.data.objects.new('Fixed game camera',d);scene.collection.objects.link(camera);scene.camera=camera
camera.location=(6,-10,6);camera.rotation_euler=(Vector((0,0,.7))-camera.location).to_track_quat('-Z','Y').to_euler();d.type='PERSP';d.sensor_fit='HORIZONTAL';d.sensor_width=36;d.lens=380*36/480;d.clip_start=.1;d.clip_end=100
scene.render.image_settings.file_format='PNG';scene.render.image_settings.color_mode='RGBA';scene.render.filepath=str(out/'alley-rgba.png');scene.render.film_transparent=False
bpy.ops.file.pack_all();bpy.ops.wm.save_as_mainfile(filepath=str(out/'alley.blend'));bpy.ops.render.render(write_still=True)
# Transparent render of the same occluder, camera and lighting for foreground repair.
for o in scene.objects:
 if o.type=='MESH' and o not in dumpster:o.hide_render=True
scene.render.film_transparent=True;scene.render.filepath=str(out/'dumpster-rgba.png');bpy.ops.render.render(write_still=True)
(out/'layout.json').write_text(json.dumps({'camera':{'x':6,'y':6,'z':-10,'yaw':-math.atan2(6,10),'pitch':-math.atan2(5.3,math.sqrt(136))},'projection':380,'assets':records},indent=2))
from bpy_extras.object_utils import world_to_camera_view
probes=[]
for x,y,z in [(-3,0,-3),(3,0,-3),(-3,0,3),(3,0,3),(0,1.85,0)]:
 p=world_to_camera_view(scene,camera,Vector((x,z,y)));probes.append([x,y,z,480*p.x,20+208*(1-p.y)])
(out/'probes.json').write_text(json.dumps(probes))
print('RENDER COMPLETE',flush=True)
os._exit(0)





