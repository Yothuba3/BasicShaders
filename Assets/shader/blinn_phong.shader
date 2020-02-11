Shader "Unlit/blinn_phong"
{
   Properties
   {
       _MainTex("Texture", 2D) = "white"{}
       //アンビエント強度　
       _Ambient("Ambient", Range(0,1)) = 0
       //アンビエントカラー　
       _AmbientColor("AmbientColor", Color) = (1,1,1,1)
       //スペキュラカラー
       _SpecColor("Specular Color", Color) = (1,1,1,1)

   }

   SubShader
   {
       Pass
       {
           Tags{"LightMode" = "ForwardBase"}

           CGPROGRAM

           #pragma vertex vert
           #pragma fragment frag

           #include "UnityCG.cginc"

           sampler2D _MainTex;
           //ライトカラー　
           float4 _LightColor0;
           //アンビエント光反射量
           float _Ambient;
           //アンビエントカラー
           float4 _AmbientColor;
           //スペキュラ色　
           float4 _SpecColor;

           struct appdata
           {
               float4 vertex : POSITION;
               float2 uv : TEXCOORD0;
               float4 normal : NORMAL;
           };

           struct v2f
           {
               float2 uv : TEXCOORD0;
               float4 vertex : SV_POSITION;
               //ワールド空間の法線ベクトル
               float3 worldNormal : TEXCOORD1;
               //ワールド空間の頂点座標
               float3 worldPos : TEXCOORD2;
           };

           v2f vert(appdata v)
           {
               v2f o;
               //頂点をクリップ空間座標に変換　
               o.vertex = UnityObjectToClipPos(v.vertex);
               //uv座標　
               o.uv = v.uv;

               //法線ベクトルをワールド空間座標に変換
               float3 worldNormal = UnityObjectToWorldNormal(v.normal);
               o.worldNormal = worldNormal;

               //頂点をワールド空間座標に変換
               float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
               o.worldPos = worldPos;

               return o;
           }

           fixed4 frag(v2f i) : SV_Target
           {
               //法線ベクトル
               float3 normal = normalize(i.worldNormal);
               //光源方向ベクトル
               float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
               //法線-ライトの角度量
               float NdotL = dot(normal, lightDir);

               //カメラ方向ベクトル
               float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

               //テクスチャマップからカラー値をサンプリング
               float4 tex = tex2D(_MainTex, i.uv);

               //拡散色の決定
               float diffusePower = max(_Ambient, NdotL);
               float4 diffuse = diffusePower * tex * _LightColor0;

               //光源方向ベクトルと視点方向ベクトルのハーフベクトル 
               float3 halfDir = normalize(lightDir + viewDir);

               //Blinnによるスペキュラ近似式
               float NdotH = dot(normal, halfDir);
               float3 specularPower = pow(max(0, NdotH), 10.0);

               //反射色の決定
               float specular = float4(specularPower, 1.0) * _SpecColor * _LightColor0;

               //拡散色のと反射色の合算
               fixed4 col = diffuse + specular;

               return col;
           }
           ENDCG
       }
   }
}
