# ttf2map

备忘
1. 等做完地图之后尝试，打包成vpk
2. 在纹理的vmf中设置贴花属性，可以有效减轻素材共面导致的纹理闪烁。
    "$decalscale" ".025"
    "$decal" "1"
3. 在树叶之类的纹理中设置通道
    "$alphatest" "1"
4. 强制将水的纹理设置为,我并不会设置流动纹理，这是武器从唐刀mod中复制过来的。
   mp_training_ground_tf2/mod/materials/models/weapons/tddr/td_col.vtf
5. 小地图
   打包在了 mp_training_ground_tf2/paks/mp_training_ground_tf2.rpak
   要在mp_training_ground_tf2/mod/resource/overviews/mp_training_ground_tf2.txt声明并调整大小和位置。感谢小b的尝试。