Shader "Unlit/cube_map"
{
    Properties
    {
        //環境マップ
        [NoScaleOffset]_CubeTex("Cube", Cube) = "" {}

    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 world_pos : TEXCOORD1;
                half3 normal : TEXCOORD2;
            };

            samplerCUBE _CubeTex;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.world_pos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //サーフェイスから視点方向のベクトルを取得
                half3 viewDir = _WorldSpaceCameraPos - i.world_pos;
                //入射ベクトルの反射ベクトルを取得
                half3 reflDir = reflect(-1 * viewDir, i.normal);
                //キューブマップと反射ベクトルから反射先の色を取得する
                half4 refColor = texCUBE(_CubeTex, reflDir);
                return refColor;
            }
            ENDCG
        }
    }
}
