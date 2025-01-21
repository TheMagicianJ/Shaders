Shader "Intro/QuadShader"
{
    Properties
    {
        _MainTexture("Main Texture", 2D) = "blue"
        _MaskTexture("Mask Texture", 2D) = "blue"

        _AnimateXY("Animation", Vector) = (0,0,0,0)
        _RevealAnimation("Reveal Animation", float) = 0
        _RevealSpeed("Reveal Speed", float) = 1

        _HiddenValue("Hidden Value", float) = 0
        _FeatherValue("Feather Value", float) = 0

        _ErodeColor("Erode Color", Vector) = (0,0,1,1)

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

        // Blending
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag   

            #include "UnityCG.cginc"
            // Main Texture
            sampler2D _MainTexture;
            float4 _MainTexture_ST;

            // Mask Texture
            sampler2D _MaskTexture;
            float4 _MaskTexture_ST;

            // Animation
            float4 _AnimateXY;
            float _RevealAnimation;
            float _RevealSpeed;

            // Mask Step Function
            float _HiddenValue, _FeatherValue;

            // Erosion
            float4 _ErodeColor;


            // Data for the mesh. Vertices
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

            // Vertext Shader
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTexture);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTexture);
                //o.uv += _AnimateXY.xy * frac(float2(_Time.y,_Time.y));
                return o;

            }
            
            // Fragment Shader
            fixed4 frag (v2f i) : SV_Target
            {
                float4 uvs = i.uv;
                fixed4 textureColor = tex2D(_MainTexture, uvs.xy);
                float4 maskColor = tex2D(_MaskTexture, uvs.zw);
                
                // Step Functions
                // smoothstep(x,y,Z) - If z is lower than x it returns 0 and if its higher than y it returns 1. Between if z is inbetween x and y it reurns a corresponding value that is interpolated between 1 and 0. Basically max value returned is 1 and lowest value is 0.
                // step(x,y) if - If y is greater than or equal to x return 1 otherwise return 0.
                
                float hidden = smoothstep(maskColor.r - _FeatherValue, maskColor.r + _FeatherValue, _HiddenValue);
                float hiddenAnim = sin(_Time.y * _RevealSpeed) * _RevealAnimation + _RevealAnimation; //0; //
                float hiddenTop = step(_HiddenValue - _FeatherValue + hiddenAnim, maskColor.r);
                float hiddenBottom = step( _HiddenValue + _FeatherValue + hiddenAnim, maskColor.r);
                float hiddenDifference = hiddenTop - hiddenBottom;
                //return fixed4(0,0,revealDifference,1);

                // Lerp Function
                // lerp(x,y,z) - Linearly interpolates betwen x and y. Returns the corresponding interpolated value to the input z. Z is clamped between 0 and 1.
                float3 lerpColor = lerp(textureColor, _ErodeColor, hiddenDifference);
                return fixed4(lerpColor, textureColor.a * hiddenTop);
            }
            ENDCG
        }
    }
}
