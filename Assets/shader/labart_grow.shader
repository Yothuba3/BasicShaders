Shader "Unlit/labart_grow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "forwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #include "UnityCG.cginc"
            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //拡散係数
                float diffuse : COLOR0;
            };

            v2f vert(appdata v){
                v2f o;
                //頂点をクリップ空間座標に変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                //uv空間
                o.uv = v.uv;
                //法線ベクトル
                float3 normal = v.normal;
                //光源方向ベクトル
                float3 lightDir = ObjSpaceLightDir(v.vertex);
                //法線 - ライトの角度量
                float NdotL = dot(normal, lightDir);
                //拡散係数の決定
                o.diffuse = max(0, NdotL);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                //テクスチャマップからカラー値をサンプリング
                float4 tex = tex2D(_MainTex, i.uv);

                //サンプリングしたカラー値に拡散係数を乗算する
                fixed4 color = i.diffuse * tex;

                return color;
            }
            ENDCG
        }
    }
}
