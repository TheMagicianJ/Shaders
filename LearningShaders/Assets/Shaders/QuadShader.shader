Shader "Intro/QuadShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "blue"
        _MaskTexture("Mask Texture", 2D) = "blue"

        _AnimateXY("Animation", Vector) = (0,0,0,0)

        _RevealValue("Reveal Value", float) = 0
        _FeatherValue("Feather Value", float) = 0

        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Source Factor", float) = 5

        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Destination Factor", float) = 10

        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", float) = 0


    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        //Blending
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            //Main Texture
            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            //Mask Texture
            sampler2D _MaskTexture;
            float4 _MaskTexture_ST;

            //Animation
            float4 _AnimateXY;

            //Mask Step Function
            float _RevealValue, _FeatherValue;

            //Data for the mesh. Vertices
            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            // v2f stands for "vert to frag". For passing vertex data to fragment shader
            struct v2f
            {
                float4 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION;
            };

            //Vertext Shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTexture);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTexture);
                //o.uv += _AnimateXY.xy * frac(float2(_Time.y,_Time.y));
                return o;

            }
            
            //Fragment Shader
            fixed4 frag (v2f i) : SV_Target
            {
                float4 uvs = i.uv;
                fixed4 textureColor = tex2D(_MainTexture, uvs.xy);
                float4 maskColor = tex2D(_MaskTexture, uvs.zw);
                
                //Step Function
                float reveal = smoothstep(_RevealValue - _FeatherValue, _RevealValue + _FeatherValue, maskColor.r) ;

                return fixed4(textureColor.rgb, textureColor.a * reveal);
            }
            ENDCG
        }
    }
}
