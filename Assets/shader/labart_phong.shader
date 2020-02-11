Shader "Unlit/labart_phong"
{
    Properties{  
        //テクスチャマップ
        _MainTex ("Texture", 2D) = "White" {}
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

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //法線ベクトル
                float3 normal = normalize(i.worldNormal);
                //ライト方向ベクトル
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //法線-ライトの角度量
                float NdotL = dot(normal, lightDir);
                //拡散係数の決定
                float diffuse = max(0, NdotL);

                //テクスチャマップからカラー値をサンプリング
                float tex = tex2D(_MainTex, i.uv);

                //カラー値決定
                fixed4 color = diffuse * tex;
                return color;
            }
            ENDCG
        }
    }
}
