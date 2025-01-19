from flask import Flask, request, send_file  
import cv2  
import os  
import subprocess  
  
app = Flask(__name__)  
  
def extract_frames(video_path, output_folder):  
    if os.path.exists(output_folder):  
        for f in os.listdir(output_folder):  
           os.remove(os.path.join(output_folder, f))  
    else:  
       os.makedirs(output_folder)  
 
  
    cap = cv2.VideoCapture(video_path)  
    frame_count = 0  
  
    while True:  
        ret, frame = cap.read()  
        if not ret:  
            break  
        cv2.imwrite(os.path.join(output_folder, f'frame_{frame_count:04d}.png'), frame)  
        frame_count += 1  
  
    cap.release()  
    # print(f"Total frame yang diekstrak: {frame_count}")  
  
def create_video_from_frames(frame_folder, output_video_path, fps=30):  
    frame_files = sorted([f for f in os.listdir(frame_folder) if f.endswith('.png')])  
  
    first_frame = cv2.imread(os.path.join(frame_folder, frame_files[0]))  
    height, width, layers = first_frame.shape  
  
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')  
    out = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))  
  
    for frame_file in frame_files:  
        frame = cv2.imread(os.path.join(frame_folder, frame_file))  
        out.write(frame)  
    out.release()  
  
@app.route('/enhance_video', methods=['POST'])  
def enhance_video():  
    if 'video' not in request.files:  
        return "Tidak ada bagian video dalam permintaan", 400  
  
    video_file = request.files['video']  
    if video_file.filename == '':  
        return "Tidak ada file yang dipilih", 400  
  
    video_path = os.path.join('uploads', video_file.filename)  
    output_folder = 'frame_output'  
    output_video_path = 'output_video.mp4'  
  
    # Simpan video yang diunggah  
    if not os.path.exists('uploads'):  
        os.makedirs('uploads')  
    video_file.save(video_path)  
  
    # Ekstrak frame dari video  
    extract_frames(video_path, output_folder)  
  
    # Tingkatkan kualitas frame menggunakan SRGAN  
    subprocess.run(['python', 'main.py', '--mode', 'test_only', '--LR_path', 'frame', '--generator_path', './model/SRGAN_gene_030.pt'])  
  
    # Buat video dari frame yang ditingkatkan kualitasnya  
    create_video_from_frames(output_folder, output_video_path)  
  
    # Kembalikan video yang ditingkatkan kualitasnya  
    return send_file(output_video_path, as_attachment=True)  
  
if __name__ == '__main__':  
    app.run(debug=True)  
